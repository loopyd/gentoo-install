#!/bin/bash

echo 'Accessing LAN...'
cd $CHROOT_MOUNT/root/
links "http://$MIRROR_SERVER_ADDRESS"

echo 'Unpacking stage 3 tarballs...'
tar xpf $CHROOT_MOUNT/root/$(ls | grep 'stage3') --xattrs-include='*.*' --numeric-owner -C $CHROOT_MOUNT
tar xpf $CHROOT_MOUNT/root/$(ls | grep 'portage') --xattrs-include='*.*'--numeric-owner -C $CHROOT_MOUNT/usr