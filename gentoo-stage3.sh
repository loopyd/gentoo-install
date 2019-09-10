#!/bin/bash

echo "${TEXT_BOLD}${TEXT_WARNING}EMERGE:${TEXT_NORMAL}${TEXT_BOLD}  Emering mirrorselect...${TEXT_NORMAL}"
emerge mirrorselect

# TODO: Fix 404 on broken mirrors by selecting several, this is a hack right now
#       You haven't seen its final form yet...  Yeah, I know.  Crazy.
echo "${TEXT_BOLD}${TEXT_WARNING}SEARCH:${TEXT_NORMAL}${TEXT_BOLD}  Getting download location.${TEXT_NORMAL}"
echo 'Locating the fastest mirror to you...'
FASTEST_MIRROR=$(mirrorselect -b50 -s1 -R "${MIRROR_REGION}" -q -o 2>/dev/null | perl -p -e 's|(GENTOO\_MIRRORS\=\")(.*)(")|${2}|g' | awk '{printf $0}')
echo 'Searching for Stage3 tarball...'
STAGE3_URL="${FASTEST_MIRROR}releases/amd64/autobuilds/"$(wget -qO- -t3 "${FASTEST_MIRROR}releases/amd64/autobuilds/latest-stage3-amd64.txt" | tail -n1 | cut -d' ' -f1)
PORTAGE_URL="${FASTEST_MIRROR}snapshots/portage-latest.tar.xz"
echo -ne '\n'
echo "    ${TEXT_BOLD}Fastest mirror:${TEXT_NORMAL} $FASTEST_MIRROR"
echo "    ${TEXT_BOLD}Stage 3 URL:${TEXT_NORMAL}    $STAGE3_URL"
echo "    ${TEXT_BOLD}Portage URL:${TEXT_NORMAL}    $PORTAGE_URL"
echo -e '\n!! IF YOU WANT MY ASCII PUKE, ITS IN THE SOURCE CODE !!\n'

mkdir -p $CHROOT_MOUNT/root/Downloads 2>/dev/null
if [ ! -f $CHROOT_MOUNT/root/Downloads/${STAGE3_URL##*/} ]; then
	rm -f $CHROOT_MOUNT/root/Downloads/stage3*.xz 2>/dev/null
	wget -t3 "${STAGE3_URL}" -O $CHROOT_MOUNT/root/Downloads/${STAGE3_URL##*/}
	echo "${TEXT_BOLD}${TEXT_OK}FETCHED:${TEXT_NORMAL}${TEXT_BOLD}  Stage 3 fetched.${TEXT_NORMAL}"
else
	echo "${TEXT_BOLD}${TEXT_ERROR}SKIPPED:${TEXT_NORMAL}${TEXT_BOLD}  Stage 3 download, already in cache!${TEXT_NORMAL}"
fi

if [ ! -f $CHROOT_MOUNT/root/Downloads/${PORTAGE_URL##*/} ]; then
	rm -f $CHROOT_MOUNT/root/Downloads/${PORTAGE_URL##*/}
	wget -t3 "${PORTAGE_URL}" -O $CHROOT_MOUNT/root/Downloads/${PORTAGE_URL##*/}
	echo "${TEXT_BOLD}${TEXT_OK}FETCHED:${TEXT_NORMAL}${TEXT_BOLD}  Portage latest snapshot fetched.${TEXT_NORMAL}"
else
	echo "${TEXT_BOLD}${TEXT_WARNING}CHECK:${TEXT_NORMAL}${TEXT_BOLD}  Portage snapshot in cache vs. online snapshot...${TEXT_NORMAL}"
	wget -t3 "${PORTAGE_URL}.md5sum" -O $CHROOT_MOUNT/root/Downloads/${PORTAGE_URL##*/}.md5sum
	cd $CHROOT_MOUNT/root/Downloads/
	if ! md5sum -c ${PORTAGE_URL##*/}.md5sum; then
		rm -f $CHROOT_MOUNT/root/Downloads/${PORTAGE_URL##*/}
		wget -t3 "${PORTAGE_URL}" -O $CHROOT_MOUNT/root/Downloads/${PORTAGE_URL##*/}
		echo "${TEXT_BOLD}${TEXT_OK}FETCHED:${TEXT_NORMAL}${TEXT_BOLD}  Portage latest snapshot fetched.${TEXT_NORMAL}"

    else
		echo "${TEXT_BOLD}${TEXT_ERROR}SKIPPED:${TEXT_NORMAL}${TEXT_BOLD}  Portage latest snapshot, already in cache!${TEXT_NORMAL}"
	fi
	cd ~
	rm -f $CHROOT_MOUNT/root/Downloads/${PORTAGE_URL##*/}.md5sum
fi

echo "${TEXT_BOLD}${TEXT_WARNING}EXTRACT:${TEXT_NORMAL}${TEXT_BOLD}  Extracting tarballs...${TEXT_NORMAL}"
echo "Extracting ${TEXT_BOLD}Stage 3${TEXT_NORMAL} tarball..."
tar xpf $CHROOT_MOUNT/root/Downloads/${STAGE3_URL##*/} --xattrs-include='*.*' --numeric-owner -C $CHROOT_MOUNT
echo "Extracting ${TEXT_BOLD}Portage Snapshot${TEXT_NORMAL} tarball..."
tar xpf $CHROOT_MOUNT/root/Downloads/${PORTAGE_URL##*/} --xattrs-include='*.*'--numeric-owner -C $CHROOT_MOUNT/usr
echo "${TEXT_BOLD}${TEXT_OK}COMPLETE:${TEXT_NORMAL}${TEXT_BOLD}  Tarballs installed.${TEXT_NORMAL}"
