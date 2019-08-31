#!/bin/bash

#- Mount point config -#
CHROOT_MOUNT='/mnt/gentoo'
HOME_LABEL='linux_home'
ROOT_LABEL='linux_root'
SWAP_LABEL='linux_swap'
VARLOG_LABEL='var_log'
HOME_MOUNT="/dev/mapper/gentoo-$HOME_LABEL"
ROOT_MOUNT="/dev/mapper/gentoo-$ROOT_LABEL"
SWAP_MOUNT="/dev/mapper/gentoo-$SWAP_LABEL"
VARLOG_MOUNT="/dev/mapper/gentoo-$VARLOG_LABEL"
BOOT_DEVICE='/dev/nvme0n1p1'
LVM_DEVICE='/dev/nvme0n1p2'
OS_DEVICE='/dev/nvme0n1'

#- Network config -#
MIRROR_SERVER_ADDRESS='192.168.1.103'
ETH0_DEVICE='enp10s0'
ETH0_ADDRESS='192.168.1.104'
ETH0_NETMASK='255.255.254.0'
ETH1_DEVICE='enp0s31f6'
ETH1_ADDRESS='192.168.1.105'
ETH1_NETMASK='255.255.254.0'
GATEWAY_ADDRESS='192.168.1.1'
DNS1_ADDRESS='8.8.8.8'
DNS2_ADDRESS='8.8.4.4'

#- Locale and timezone config -#
DEFAULT_LOCALE='en_US.UTF-8'
LOCALES_TOGEN='en_US ISO-8859-1
en_US.UTF-8 UTF-8'
TIMEZONE='America/New_York'

#- Account credential config -#
USERNAME="heavypaws"
PASSWORD="p4ssw0rd"
ROOT_PASSWORD="p4ssw0rd"

#- Initramfs settings -#
DRACUT_KVER='5.1.7-ck'
DRACUT_MODULES='lvm dm'
DRACUT_KERNEL_MODULES='efivarfs igb bluetooth nvme-core nvme nvidia thunderbolt-net iptable_nat bpfilter team team_mode_broadcast team_mode_loadbalance team_mode_roundrobin vfio vfio_iommu_type1 vfio-pci'

#- Internal script settings -#
# Do not change these
TEXT_BOLD=$(tput bold)
TEXT_NORMAL=$(tput sgr0)
TEXT_ERROR=$(tput setaf 1)
TEXT_WARNING=$(tput setaf 3)
TEXT_OK=$(tput setaf 6)