#!/bin/bash

echo 'Mounting base filesystem...'
swapon $SWAP_MOUNT
mkdir $CHROOT_MOUNT
mount --types xfs --options rw,noatime,attr2,inode64,noquota $ROOT_MOUNT $CHROOT_MOUNT
mkdir --parents $CHROOT_MOUNT/proc $CHROOT_MOUNT/sys $CHROOT_MOUNT/dev $CHROOT_MOUNT/dev/shm $CHROOT_MOUNT/dev/pts $CHROOT_MOUNT/var/tmp/portage $CHROOT_MOUNT/var/log $CHROOT_MOUNT/boot/efi $CHROOT_MOUNT/tmp $CHROOT_MOUNT/root $CHROOT_MOUNT/home $CHROOT_MOUNT/run
mount --types ext4 --options rw,noatime,noquota $HOME_MOUNT $CHROOT_MOUNT/home
mount --types vfat --options rw,noatime $BOOT_DEVICE $CHROOT_MOUNT/boot/efi
mount --types ext4 --options rw,noatime $VARLOG_MOUNT $CHROOT_MOUNT/var/log