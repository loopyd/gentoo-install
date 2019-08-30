#!/bin/bash

echo 'Creating filesystem...'
sgdisk -ozg $OS_DEVICE
sgdisk -n 1:2048:+500M -c 1:"EFI System Partition" -t 1:ef00 $OS_DEVICE
sgdisk -n 2 -c 2:"Linux LVM" -t 2:8e00 $OS_DEVICE 

echo 'Creating LVM...'
pvcreate $LVM_DEVICE 
vgcreate -f gentoo $LVM_DEVICE
lvcreate -y -L 4G -n $SWAP_LABEL gentoo
lvcreate -y -L 4G -n $VARLOG_LABEL gentoo 
lvcreate -y -l50%FREE -n $ROOT_LABEL gentoo 
lvcreate -y -l100%FREE -n $HOME_LABEL gentoo 

echo 'Formatting filesystems...'
mkfs.vfat -F32 $BOOT_DEVICE 
mkfs.xfs -f $ROOT_MOUNT 
mkfs.ext4 -F $HOME_MOUNT 
mkfs.ext4 -F $VARLOG_MOUNT
mkswap -f $SWAP_MOUNT

vgchange -a y gentoo 
partprobe