#!/bin/bash

TIMER_PID=0

function flaggie_wrapper() {
	local ATOM="$1"
	shift
	local FLAGS="$@"
	echo -ne "\033[2K\033[200D    [${TEXT_BOLD}flaggie${TEXT_NORMAL}] ${ATOM} ${TEXT_WARNING}${FLAGS}${TEXT_NORMAL}"
	flaggie --destructive-cleanup
	flaggie "$ATOM" $FLAGS
	rm -f /etc/portage/package.use/*~
	rm -f /etc/portage/package.mask/*~
	rm -f /etc/portage/package.unmask/*~
	rm -f /etc/portage/package.license/*~
	rm -f /etc/portage/package.accept_keywrods/*~
	echo -ne " [${TEXT_OK}done${TEXT_NORMAL}]"
}

function etc_update_wrapper() {
	echo -ne "\033[2K\033[200D    [${TEXT_BOLD}etc-update${TEXT_NORMAL}] Running... "
	local UPD_OUT=
	while [[ -n $UPD_OUT ]]; do
 		UPD_OUT=$(echo "yes" | etc-update --automode -3)
		if [[ $UPD_OUT == *"updates remaining"* ]]; then
			UPD_OUT=
		fi
	done
	echo -ne " [${TEXT_OK}done${TEXT_NORMAL}]"
}

function emerge_wrapper() {
	local GARGS=()
	local EMERGE_ARGS=()
	local EMERGE_ATOMS=()
	read -ra GARGS <<< "$@"
	LFS=' ' read -ra EMERGE_ARGS <<< $(for GARG in "${GARGS[@]}"; do
		if [[ $GARG =~ ^[-]{1,2} ]]; then
			echo -n "$GARG "
		fi
	done)
	LFS=' ' read -ra EMERGE_ATOMS <<< $(for GARG in "${GARGS[@]}"; do
		if [[ $GARG =~ ^[[:alnum:]/\=:@\_\>\<\.\-]+ ]] && ! [[ $GARG =~ ^[-]{1,2} ]]; then
			echo -n "${GARG} "
		fi
	done)
	
	coproc { emerge "${EMERGE_ARGS[@]}" "${EMERGE_ATOMS[@]}" ; } 2>&1
	while kill -0 $COPROC_PID 2>/dev/null; do
		while IFS='' read -d'' -u "${COPROC[0]}" line; do
			if [[ $(echo -n "$line" | cut -d')' -f2 | cut -d' ' -f2) =~ ^[[:alnum:]/\=:\@\_\>\<\.\-]+ ]]; then
				echo -ne "\033[2K\033[200D    [${TEXT_BOLD}emerge${TEXT_NORMAL}] "$(echo -n "$line" | cut -d')' -f2 | cut -d' ' -f2)
			fi
		done
	done
	wait $COPROC_PID 2>/dev/null
}

function kernel_wrapper() {
	local OPT="$1"
	echo -ne "${TEXT_WARNING}"$(echo "$OPT" | cut -c1)"${TEXT_NORMAL}"
	yes "" | make -s "$OPT" >/dev/null 2>&1
	echo -ne "\033[1D${TEXT_OK}"$(echo "$OPT" | cut -c1)"${TEXT_NORMAL} "
}

#- SCRIPT WRAPPER FUNCTIONS -#

# Displays the header (or footer) of the script wrapper.
function scriptwrapper_display_msg() {
	local i="$1"
	local MSG
	local COMMAND
	local DISPLAY_COMMAND="$2"
	local DISPLAY_REGEX
	shopt -s nocasematch
	shopt -s extglob
	
	case "${i}" in
		*error*)
			MSG="${TEXT_BOLD}${TEXT_ERROR}${i}${TEXT_NORMAL}"
			;;
		*warning*)
			MSG="${TEXT_BOLD}${TEXT_WARNING}${i}${TEXT_NORMAL}"
			;;
		*success*|*complete*)
			MSG="${TEXT_BOLD}${TEXT_OK}${i}${TEXT_NORMAL}"
			;;
		*)
			MSG="${TEXT_BOLD}${TEXT_OK}${i}${TEXT_NORMAL}"
			;;
	esac
	
	if [[ $DISPLAY_COMMAND =~ ^[.]([[:space:]]*).*$ ]] || [[ $DISPLAY_COMMAND =~ ^source([[:space:]]*).*$ ]]; then
		DISPLAY_COMMAND=$(echo -n "${DISPLAY_COMMAND}" | cut -d' ' -f2)
		DISPLAY_COMMAND="${DISPLAY_COMMAND##*/}";
		COMMAND=$(echo -n "${DISPLAY_COMMAND}" | cut -d' ' -f1)
	elif [[ $DISPLAY_COMMAND =~ chroot([[:space:]]*)(.*) ]]; then
		DISPLAY_COMMAND=$(echo -n "${DISPLAY_COMMAND}" | cut -d' ' -f4)
		DISPLAY_COMMAND="${DISPLAY_COMMAND##*/}";
		COMMAND=$(echo -n "${DISPLAY_COMMAND}" | cut -d' ' -f1)
	else
		COMMAND=$(echo -n "${DISPLAY_COMMAND}" | cut -d' ' -f1)
	fi
	
	COMMAND="${TEXT_WARNING}${COMMAND}${TEXT_NORMAL}"
	printf %"$(tput cols)"s |tr " " "="
	printf "%-40s %40s\n" "  $MSG" "${COMMAND}"
	printf %"$(tput cols)"s |tr " " "="
	echo -e "\n"
	
	shopt -u extglob
	shopt -u nocasematch
}

# Cleans up any thing done to the environment by the script wrapper.
function scriptwrapper_cleanup() {
	shopt -u extglob 2>/dev/null
	shopt -u nocasematch 2>/dev/null
	unset error 2>/dev/null
	unset out 2>/dev/null
}

# Runs another script by sourcing it to pull in the GentooDAD config chain.
function scriptwrapper() {
	local WRAPPER_TEXT="$1"
	local WRAPPER_COMMAND="$2"

	scriptwrapper_display_msg "$WRAPPER_TEXT" "$WRAPPER_COMMAND"

	shopt -s nocasematch
	if [[ $WRAPPER_COMMAND =~ ^[.][[:space:]].*$ ]] || [[ $DISPLAY_COMMAND =~ ^source[[:space:]].*$ ]]; then
		{ error=$($WRAPPER_COMMAND 2>&1 1>&$out); } {out}>&1
	elif [[ $WRAPPER_COMMAND =~ ^chroot[[:space:]].*$ ]]; then
		$WRAPPER_COMMAND
	else
		{ error=$($WRAPPER_COMMAND 2>&1 1>&$out); } {out}>&1
	fi

	if [[ $error =~ ^.*(failed[[:space:]]*to|error:[[:space:]]*|cannot[[:space:]]read|invalid[[:space:]]option|invalid[[:space:]]syntax|expected[[:space:]]*|please[[:space:]]correct|please[[:space:]]fix|exception[[:space:]]occoured).*$ ]]; then
		shopt -u nocasematch
		echo -e "\n"
		scriptwrapper_display_msg 'Error occoured' "$WRAPPER_COMMAND"
		echo -e "An error has occoured in the script, the output is below:\n"
		echo "${TEXT_BOLD}${TEXT_ERROR}$error${TEXT_NORMAL}"
		echo -e "\nThe script will now terminate\n"
		scriptwrapper_cleanup
		exit
	elif [[ "$error x" != " x" ]]; then
		echo -e "\n"
		scriptwrapper_display_msg 'Warnings' "$WRAPPER_COMMAND"
		echo -e "Some warnings where generated.  Typically, emerge operations will write\nsome output to stderror, in that case, you can ignore this output,\nunless you are debugging.\n"
		echo "${TEXT_BOLD}${TEXT_WARNING}$error${TEXT_NORMAL}"
		scriptwrapper_cleanup
	else
		scriptwrapper_cleanup
		echo -e "\n"
		scriptwrapper_display_msg 'Operation completed' "$WRAPPER_COMMAND"
	fi
}

#- TARBALL FETCHING -#
# Checksum a tarball file using a source URI.
function checksum_tarball() {
	local URI="$1"
	#- CONFUSION! -#
	#
	# >,.,> the following statement is wildly complex due to the different way
	#       mirrors store checksum information.  I've gone through 17 different mirrors
	#       to have a look at the 'standards'.  Well, at leas you can determine the format
	#       by extension.  FTP mirrors typically use a DIGEST file with a sha512 checksum, while
	#       http/https mirrors use a sha256sum/sha512sum/md5sum file.  I'll use some awk magic to 
	#       do this checksum verification completely inline.  Having to pack these into one
	#       long multiline if statement is pure bash vomit, but it works reliably for most
	#       mirrors I've tossed it at, which is the most important thing.
	#
	#       The drawback to this method is that stderror will be populated with one or many
	#       404 errors.  That is unavoidable.  Only one condition has to resolve to true.
	#
	if [ -f $CHROOT_MOUNT/tmp/${URI##*/} ]; then
		if [[ $(sha512sum $CHROOT_MOUNT/tmp/${URI##*/} | awk -F'  ' '{print $1}') == \
			  $(wget -t3 "${URI}.DIGESTS" -qO- | grep -A 1 -i sha512 | head -n 2 | tail -n 1 | awk -F'  ' '{print $1}') ]] || \
		   [[ $(sha256sum $CHROOT_MOUNT/tmp/${URI##*/} | awk -F'  ' '{print $1}') == \
		      $(wget -t3 "${URI}.sha256sum" -qO- | grep -i ${URI##*/} | awk -F'  ' '{print $1}') ]] || \
		   [[ $(sha512sum $CHROOT_MOUNT/tmp/${URI##*/} | awk -F'  ' '{print $1}') == \
		      $(wget -t3 "${URI}.sha512sum" -qO- | grep -i ${URI##*/} | awk -F'  ' '{print $1}') ]] || \
		   [[ $(md5sum $CHROOT_MOUNT/tmp/${URI##*/} | awk -F'  ' '{print $1}') == \
		      $(wget -t3 "${URI}.md5sum" -qO- | grep -i ${URI##*/} | awk -F'  ' '{print $1}') ]]; then
			echo -ne "1"
		else
			echo -ne "0"
		fi
	else
		echo -ne "2"
	fi
}

# Fetch a tarball for the Gentoo System from a mirror URI.
function fetch_tarball() {
	local FETCH_URI="$1"
	case $(checksum_tarball "$FETCH_URI") in
		0*)
			rm -f $CHROOT_MOUNT/tmp/${FETCH_URI##*/}
			wget -t3 "${FETCH_URI}" -qO $CHROOT_MOUNT/tmp/${FETCH_URI##*/}
			if [ $? -eq 0 ]; then
				echo -ne "1"
			else
				echo -ne "0"
			fi
			;;
		1*)
			echo -ne "1"
			;;
		2*)
			wget -t3 "${FETCH_URI}" -qO $CHROOT_MOUNT/tmp/${FETCH_URI##*/}
			if [ $? -eq 0 ]; then
				echo -ne "1"
			else
				echo -ne "0"
			fi
			;;
	esac
}

# Wrapper for Stage3 and Portage installation
function fetch_tarball_wrapper() {
	local -n MIRRORS=$1
	shift
	local TARBALL_NAME="$1"
	shift
	local TARBALL_EXTRACT_DIR="$1"
	
	local MIRROR_SUCCESS=0
	local MIRROR_TARBALL_URI="null"
	
	for MIRROR in "${MIRRORS[@]}"; do
		echo -ne "\033[2K\033[200D    [${TEXT_BOLD}$TARBALL_NAME${TEXT_NORMAL}] ${TEXT_WARNING}fetch${TEXT_NORMAL}"
		case "$TARBALL_NAME" in
			stage3*)
				MIRROR_TARBALL_URI="${MIRROR}releases/amd64/autobuilds/"$(wget -qO- -t3 "${MIRROR}releases/amd64/autobuilds/latest-stage3-amd64.txt" | tail -n1 | cut -d' ' -f1)
				;;
			portage*)
				MIRROR_TARBALL_URI="${MIRROR}snapshots/portage-latest.tar.xz"
				;;
		esac
		if [[ $(fetch_tarball "$MIRROR_TARBALL_URI") == "1" ]]; then
			echo -ne "\033[5D${TEXT_OK}fetch${TEXT_NORMAL} ${TEXT_WARNING}move${TEXT_NORMAL}"
			mv $CHROOT_MOUNT/tmp/${MIRROR_TARBALL_URI##*/} $CHROOT_MOUNT/root/${MIRROR_TARBALL_URI##*/}
			chown root:root $CHROOT_MOUNT/root/${MIRROR_TARBALL_URI##*/}
			echo -ne "\033[4D${TEXT_OK}move${TEXT_NORMAL} ${TEXT_WARNING}extract${TEXT_NORMAL}"
			tar xpsf $CHROOT_MOUNT/root/${MIRROR_TARBALL_URI##*/} --xattrs-include='*.*' --numeric-owner -C $TARBALL_EXTRACT_DIR >/dev/null 2>&1
			if ! [ $? -eq 0 ]; then
				# Sometimes a shitty mirror maintainer causes this situation, valid package
				# but they've probably never tested the tarball themselves.  -.-
				#
				# If I wanted to be a true whitehat I'd syscall sendmail to scream-out the
				# webmaster in hAcKeR CaPs everytime my script fials to extract their tarballs.
				#
				# Leave shitty admins where they lay...
				#
				echo -ne "\033[7D${TEXT_ERROR}extract${TEXT_NORMAL} ${TEXT_WARNING}clean${TEXT_NORMAL}"
				rm -f $CHROOT_MOUNT/root/${MIRROR_TARBALL_URI##*/}
				echo -ne "\033[5D${TEXT_OK}clean${TEXT_NORMAL} ${TEXT_ERROR}${TEXT_BOLD}Retrying with another mirror...${TEXT_NORMAL}"
				sleep 3
				continue
			fi
			echo -ne "\033[7D${TEXT_OK}extract${TEXT_NORMAL} ${TEXT_WARNING}clean${TEXT_NORMAL}"
			rm -f $CHROOT_MOUNT/root/${MIRROR_TARBALL_URI##*/}
			echo -ne "\033[5D${TEXT_OK}clean${TEXT_NORMAL} [${TEXT_BOLD}${TEXT_OK}done${TEXT_NORMAL}]"
			sleep 3
			break
		else
			echo -ne "\033[5D${TEXT_ERROR}fetch${TEXT_BOLD} Retrying with another mirror...${TEXT_NORMAL}"
			sleep 3
		fi
	done
}

#- TIMER FUNCTIONS -#
# Displays a process timer which runs as a background process 
function timer_init()
	{
	SECONDS=0
	while true
	do
		sleep 1
		printf -v ELAPSED "%02d:%02d:%02d" $(($SECONDS / 3600)) $((($SECONDS / 60) % 60)) $(($SECONDS % 60))
		echo -ne "\033[s\033[1B\033[200D    [${TEXT_ERROR}${TEXT_BOLD}time${TEXT_NORMAL}] ${TEXT_WARNING}$ELAPSED${TEXT_OK}\033[u"
	done
	} &
	TIMER_PID=$!
}

#- Kills a running process timer -#
function timer_kill() {
	kill $TIMER_PID 
	wait $TIMER_PID 2>/dev/null
}