#!/bin/bash

# This module is not working yet (alpha-staging)
# But you can preview all this if you want to .

read -a GARGS <<< "$@"
LFS=' '; read -a PASSED_ARGS <<< $(for GARG in "${GARGS[@]}"; do
	if [[ $GARG =~ ^[-]{1,2} ]]; then
		echo -n "$GARG "
	fi
done)
read -a PORTAGE_ARGS <<< $(perl -n -e '/(EMERGE\_DEFAULT\_OPTS\=\")(.+)(\")/ && print $2' /etc/portage/make.conf)
read -a EMERGE_ARGS <<< $(merge_array PASSED_ARGS PORTAGE_ARGS)	

function merge_array() {
	local -n LARGS=$1
	local -n RARGS=$2
		
	# Merge args which are the same
	for LARG in "${LARGS[@]}"; do
		for RARG in "${RARGS[@]}"; do
			[[ $LARG == "$RARG" ]] && { echo -n "$LARG "; break; }
		done
	done
	# Merge args which are new
	for LARG in "${LARGS[@]}"; do
		skip=
		for RARG in "${RARGS[@]}"; do
			[[ $LARG == "$RARG" ]] && { skip=1; break; }
		done
		[[ -n $skip ]] || echo -n "$LARG "
	done
	# Merge args which are old
	for RARG in "${RARGS[@]}"; do
		skip=
		for LARG in "${LARGS[@]}"; do
			[[ $LARG == "$RARG" ]] && { skip=1; break; }
		done
		[[ -n $skip ]] || echo -n "$RARG "
	done
}

function flaggie_wrapper() {
	local FLAGGIE_ATOM="$1"
	shift
	local -n FLAGGIE_CHANGES=$1
	local WORK_ATOMS
	local WORK_FLAGS
	local WORK_NODE
	local LNUMBER
	local MATCH
	echo -e "${TEXT_BOLD}${TEXT_WARNING}FLAGGIE:${TEXT_NORMAL} Searching for matching atom:\n    ${TEXT_BOLD}${FLAGGIE_ATOM}${TEXT_NORMAL}\n"
	for f in /etc/portage/package.use/* ; do
		IFS=$'\n' read -a WORK_ATOMS <<< $(cat $f | grep -v '^$\|^\s*\#' | perl -n -e '/^([a-zA-Z0-9\-\:\/\>\<\=\_\.\+]+)[\s]+([a-zA-Z0-9\-\_\s]+)$/ && print "$1\n"')
		IFS=$'\n' read -a WORK_FLAGS <<< $(cat $f | grep -v '^$\|^\s*\#' | perl -n -e '/^([a-zA-Z0-9\-\:\/\>\<\=\_\.\+]+)[\s]+([a-zA-Z0-9\-\_\s]+)$/ && print "$2\n"')
		LNUMBER=1
		MATCH=
		for ln in "${WORK_ATOMS[@]}"; do
			if [[ $FLAGGIE_ATOM == *"$ln"* ]] || [[ $ln == *"$FLAGGIE_ATOM"* ]]; then
				if ! [[ -n $MATCH ]]; then 
					echo -e "    ${TEXT_OK}MATCH: ${TEXT_NORMAL}${TEXT_BOLD}$FLAGGIE_ATOM${TEXT_NORMAL}\n        Match on line ${TEXT_BOLD}$LNUMBER${TEXT_NORMAL} of ${TEXT_BOLD}$f${TEXT_BOLD}"
					MATCH="$f,$LNUMBER,"$(echo ${FLAGGIE_ATOM} | perl -n -e '/(.*)\/(.*)/ && print $1' | sed 's/[=><]//g')
					sed -i -e "${LNUMBER}d" $f
				else
					echo -e "    ${TEXT_WARNING}DUPLICATE: ${TEXT_NORMAL}${TEXT_BOLD}$FLAGGIE_ATOM${TEXT_NORMAL}\n        Duplicate on line ${TEXT_BOLD}$LNUMBER${TEXT_NORMAL} of ${TEXT_BOLD}$f${TEXT_BOLD}"
					sed -i -e "${LNUMBER}d" $f
				fi
			fi
			LNUMBER=$((LNUMBER+1))
		done
		# Comment line to avoid bash confusion
	done
	echo 'Running flaggie...'
	touch /etc/portage/package.use/zzzz-flaggie
	flaggie \>=$FLAGGIE_ATOM ${FLAGGIE_CHANGES[@]}
}

function emerge_wrapper() {
	local -n LARGS=$1
	local EMERGE_ATOMS

	IFS=' ' read -a EMERGE_ATOMS <<< $(for LARG in "${LARGS[@]}"; do
		if [[ $LARG =~ ^[[:alnum:]/=:@\>\<\.\-]+ ]] && ! [[ $LARG =~ ^[-]{1,2} ]]; then
			echo -n "${LARG} "
		fi
	done)
	
	local PACKAGE_NODE
	local PACKAGE_NAME
	local PACKS
	local EMERGE_ERRORS
	local SLOT_COLLIDER_FIXES
	local CIRCULAR_COLLIDER_FIXES
	local FIX_ATOM
	local FIX_SUGGESTIONS
	for ATOM in "${EMERGE_ATOMS[@]}"; do
		PACKAGE_NODE=$(echo ${ATOM} | perl -n -e '/(.*)\/(.*)/ && print $1' | sed 's/[=><]//g')
		if [[ $ATOM == "@"* ]]; then
			echo "${TEXT_BOLD}${TEXT_OK}GROUP: ${TEXT_NORMAL} ${TEXT_BOLD}Package Group:${TEXT_NORMAL} $ATOM ..."
			IFS=$'\n' read -d '' -r -a PACKS <<< $(equery --quiet list $ATOM)
			emerge_wrapper PACKS
		else
			echo "${TEXT_BOLD}${TEXT_WARNING}SCAN:${TEXT_NORMAL} ${TEXT_BOLD}Pretending Install:${TEXT_NORMAL} $ATOM ..."
			EMERGE_ERRORS=$(emerge --pretend ${EMERGE_ARGS[@]} $ATOM 2>&1 >/dev/null)
			IFS=$'\n' read -d '' -r -a SLOT_COLLIDER_FIXES <<< $(echo "$EMERGE_ERRORS" | sed -n -e '/It\ might\ be\ possible\ to\ solve\ this\ slot\ collision/,/^\s*$/p' | perl -n -e '/^[\-\s]+(.+)[\s](\(Change[\s+]USE\:[\s+])(.+)[\)]$/ && print "$1 $3\n"')
			IFS=$'\n' read -d '' -r -a CIRCULAR_COLLIDER_FIXES <<< $(echo "$EMERGE_ERRORS" | sed -n -e '/It\ might\ be\ possible\ to\ break\ this\ cycle/,/^\s*$/p' | perl -n -e '/^[\-\s]+(.+)[\s](\(Change[\s+]USE\:[\s+])(.+)[\)]$/ && print "$1 $3\n"')
			for FIX in "${SLOT_COLLIDER_FIXES[@]}"; do
				echo -e "${TEXT_BOLD}${TEXT_WARNING}SLOT COLLDE:${TEXT_NORMAL} Slot collision resolution needed during:\n    Pretend phase: ${TEXT_BOLD}${ATOM}${TEXT_NORMAL}\n\n    flaggie will be run to resolve this collission\n    You may see this message multiple times\n"
				FIX_ATOM=$(echo -n "$FIX" | perl -n -e '/^(.*)[\s]+([a-zA-Z0-9\-\+]+)$/ && print "$1"')
				IFS=' ' read -a FIX_SUGGESTIONS <<< $(echo -n "$FIX" | perl -n -e '/^(.*)[\s]+([a-zA-Z0-9\-\+\s]+)$/ && print "$2"')
				flaggie_wrapper "$FIX_ATOM" FIX_SUGGESTIONS
			done
			for FIX in "${CIRCULAR_COLLIDER_FIXES[@]}"; do
				echo -e "${TEXT_BOLD}${TEXT_WARNING}CIRCULAR CONDITION:${TEXT_NORMAL} Circular resolution needed during:\n    Pretend phase: ${TEXT_BOLD}${ATOM}${TEXT_NORMAL}\n\n    flaggie will be run to resolve this condition\n    You may see this message multiple times\n"
				FIX_ATOM=$(echo -n "$FIX" | perl -n -e '/^(.*)[\s]+([a-zA-Z0-9\-\+]+)$/ && print "$1"')
				IFS=' ' read -a FIX_SUGGESTIONS <<< $(echo -n "$FIX" | perl -n -e '/^(.*)[\s]+([a-zA-Z0-9\-\+\s]+)$/ && print "$2"')
				flaggie_wrapper "$FIX_ATOM" FIX_SUGGESTIONS
			done
			echo "$EMERGE_ERRORS"
		fi
	done
}

emerge_wrapper GARGS

