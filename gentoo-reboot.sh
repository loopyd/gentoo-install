#!/bin/bash

umount -l $CHROOT_MOUNT/sys
umount -l $CHROOT_MOUNT/proc
umount $CHROOT_MOUNT/dev/pts
umount $CHROOT_MOUNT/dev/shm
umount -l $CHROOT_MOUNT/dev
umount -l $CHROOT_MOUNT/var/tmp/portage
umount -l $CHROOT_MOUNT/var/tmp
umount -l $CHROOT_MOUNT/var/log
umount -l $CHROOT_MOUNT/boot/efi
umount -l $CHROOT_MOUNT/tmp
umount -l $CHROOT_MOUNT/home
umount -l $CHROOT_MOUNT
reboot