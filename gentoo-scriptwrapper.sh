#!/bin/bash

#- COMPILICATED -#
# Probably one of the more complicated parts of the script - the error and warning handler.
# Well, its for usability and easy debug, after all.  Here goes.
WRAPPER_TEXT="$1"
WRAPPER_COMMAND="$2"

function display_msg() {
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

function wrapper_cleanup() {
	shopt -u extglob 2>/dev/null
	shopt -u nocasematch 2>/dev/null
	unset error 2>/dev/null
	unset out 2>/dev/null
}

display_msg "$WRAPPER_TEXT" "$WRAPPER_COMMAND"
sleep 2s

#- CONFUSING BIT -#
shopt -s nocasematch
if [[ $WRAPPER_COMMAND =~ ^[.]([[:space:]]*).*$ ]] || [[ $DISPLAY_COMMAND =~ ^source([[:space:]]*).*$ ]]; then
	{ error=$($WRAPPER_COMMAND 2>&1 1>&$out); } {out}>&1
elif [[ $WRAPPER_COMMAND =~ chroot([[:space:]]*)(.*) ]]; then
	$WRAPPER_COMMAND
else
	{ error=$($WRAPPER_COMMAND 2>&1 1>&$out); } {out}>&1
fi

if [[ $error =~ ^.*(failed[[:space:]]*to|error:[[:space:]]*|cannot[[:space:]]read|invalid[[:space:]]option|invalid[[:space:]]syntax|expected[[:space:]]*|please[[:space:]]correct|please[[:space:]]fix|exception[[:space:]]occoured).*$ ]]; then
	shopt -u nocasematch
	echo -e "\n"
	display_msg 'Error occoured' "$WRAPPER_COMMAND"
	echo -e "An error has occoured in the script, the output is below:\n"
	echo "${TEXT_BOLD}${TEXT_ERROR}$error${TEXT_NORMAL}"
	echo -e "\nThe script will now terminate\n"
	wrapper_cleaup
	exit
elif [[ "$error x" != " x" ]]; then
	echo -e "\n"
	display_msg 'Warnings' "$WRAPPER_COMMAND"
	echo -e "Some warnings where generated.  Typically, emerge operations will write\nsome output to stderror, in that case, you can ignore this output,\nunless you are debugging.\n"
	echo "${TEXT_BOLD}${TEXT_WARNING}$error${TEXT_NORMAL}"
	wrapper_cleanup
else
	wrapper_cleanup
	echo -e "\n"
	display_msg 'Operation completed' "$WRAPPER_COMMAND"
fi

unset error
unset out
sleep 3s
