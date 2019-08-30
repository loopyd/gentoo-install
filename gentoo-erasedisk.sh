#!/bin/bash

echo 'Removing any existing filesystems...'
lvremove -f gentoo 2>/dev/null
vgremove -f gentoo $LVM_DEVICE 2>/dev/null
pvremove -f $LVM_DEVICE 2>/dev/null
rm -rd $CHROOT_MOUNT 2>/dev/null
wipefs -af $OS_DEVICE 2>/dev/null
partprobe $OS_DEVICE
