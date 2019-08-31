#!/bin/bash

# The Linux Distro personality blurb:
# "Gentoo - Sad neckbeards who don't talk to people IRL and don't have a girlfriend."
#
# LETS CHANGE THAT !

chmod +x ./*.sh
. ./gentoo-config.sh
. ./gentoo-anim.sh

msg_anim 'Welcome to the installer!' 'This took about 3 months to write' '5'
msg_anim 'This script is very long' 'Sit back, relax, and enjoy!' '10'

. ./gentoo-scriptwrapper.sh 'Unmounting filesystem for safety' './gentoo-unmount.sh'
. ./gentoo-scriptwrapper.sh 'Erasing disk' './gentoo-erasedisk.sh'
. ./gentoo-scriptwrapper.sh 'Formatting disk' './gentoo-formatdisk.sh'
. ./gentoo-scriptwrapper.sh 'Mounting the base filesystem' './gentoo-mountbase.sh'
. ./gentoo-scriptwrapper.sh 'Stage3 setup' './gentoo-stage3.sh'
. ./gentoo-scriptwrapper.sh 'Mounting tmpfs' './gentoo-mounttmp.sh'
. ./gentoo-scriptwrapper.sh 'Injecting configuration' './gentoo-injectconfig.sh'

msg_anim 'Chroot' 'The next stage of the installer runs in the chroot.' '5'

. ./gentoo-scriptwrapper.sh 'Running in chroot' "chroot $CHROOT_MOUNT /bin/bash /root/gentoo-chroot-innerscript.sh"
. ./gentoo-reboot.sh