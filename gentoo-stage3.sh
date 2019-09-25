#!/bin/bash

echo -ne "${TEXT_BOLD}Installing Stage3${TEXT_NORMAL}\n\n    This process can take a long time depending on the speed of your Internet.\n    I will try the 3 closest mirrors.  If you recieve a crash\n    please check your installation media's network connection.\n\n\n\033]1A"

timer_init

emerge_wrapper mirrorselect

echo -ne "\033[2K\033[200D    [${TEXT_BOLD}init${TEXT_NORMAL}] ${TEXT_WARNING}mirrorselect${TEXT_NORMAL}"
LFS=' ' read -ra FASTEST_MIRRORS <<< $(mirrorselect -b50 -s3 -R "${MIRROR_REGION}" -q -o 2>/dev/null | perl -p -e 's|(GENTOO\_MIRRORS\=\")(.*)(")|${2}|g')
mkdir -p $CHROOT_MOUNT/root/Downloads 2>/dev/null
echo -ne "\033[12D${TEXT_OK}mirrorselect${TEXT_NORMAL} [${TEXT_BOLD}${TEXT_OK}done${TEXT_NORMAL}]"
sleep 1

fetch_tarball_wrapper FASTEST_MIRRORS "stage3" "$CHROOT_MOUNT" 
fetch_tarball_wrapper FASTEST_MIRRORS "portage" "$CHROOT_MOUNT/usr"

timer_kill

echo -ne "\033[2K\033[200D\n\033[2K\033[200D\033[1A    ${TEXT_BOLD}${TEXT_OK}Stage 3 Install Finished!${TEXT_NORMAL}]\n\n"

