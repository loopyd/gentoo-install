#!/bin/bash

echo 'Removing any existing filesystems...'
vgremove -f gentoo 2>/dev/null
pvremove -f $LVM_DEVICE 2>/dev/null 
rm -rd $CHROOT_MOUNT 2>/dev/null
wipefs -af $OS_DEVICE 2>/dev/null
