#!/bin/bash

echo 'Mounting temporary filesystem...'
mount --rbind /proc $CHROOT_MOUNT/proc
mount --make-rslave $CHROOT_MOUNT/proc
mount --rbind /sys $CHROOT_MOUNT/sys
mount --make-rslave $CHROOT_MOUNT/sys
mount --rbind /dev $CHROOT_MOUNT/dev
mount --make-rslave $CHROOT_MOUNT/dev
test -L /dev/shm && rmdir /dev/shm && mkdir /dev/shm 
mount -t devpts -o rw,remount,nosuid,noexec,relatime,gid=5,mode=620 -force none $CHROOT_MOUNT/dev/pts
mount --types tmpfs --options rw,nosuid,noatime,nodev,mode=1777 tmpfs $CHROOT_MOUNT/tmp
mount --types tmpfs --options rw,nosuid,noatime,nodev,mode=1777,size=16G tmpfs $CHROOT_MOUNT/var/tmp
mount --types tmpfs --options rw,nosuid,noatime,nodev,mode=755,size=16G,uid=portage,gid=portage,x-mount.mkdir=755 tmpfs $CHROOT_MOUNT/var/tmp/portage
