#!/bin/bash

#- Unmount for safety -#
swapoff $SWAP_MOUNT
umount -l $CHROOT_MOUNT
echo 'Waiting for filesystem to dismount...'
while mountpoint -q "$CHROOT_MOUNT"; do
	sleep 1s
done