#!/bin/bash

chmod +x ./*.sh
. ./gentoo-config.sh
. ./gentoo-wrappers.sh

scriptwrapper 'Unmounting filesystem for safety' '. ./gentoo-unmount.sh'
scriptwrapper 'Erasing disk' '. ./gentoo-erasedisk.sh'
scriptwrapper 'Formatting disk' '. ./gentoo-formatdisk.sh'
scriptwrapper 'Mounting the base filesystem' '. ./gentoo-mountbase.sh'
scriptwrapper 'Fixing LiveCD portage' '. ./gentoo-fixliveportage.sh'
scriptwrapper 'Stage3 setup' '. ./gentoo-stage3.sh'
scriptwrapper 'Mounting tmpfs' '. ./gentoo-mounttmp.sh'
scriptwrapper 'Injecting configuration' '. ./gentoo-injectconfig.sh'
scriptwrapper 'Automakeonf running' '. ./gentoo-automakeconf.sh'
scriptwrapper 'Running in chroot' "chroot $CHROOT_MOUNT /bin/bash /root/gentoo-chroot-innerscript.sh"
#. ./gentoo-reboot.sh