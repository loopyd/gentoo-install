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
MIRROR_REGION='North America'
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

# Kernel config
KERNEL_RELEASE_VER='gentoo'
KERNEL_FULL_VER='5.2.8'
KERNEL_MINOR_VER=$(echo -n $KERNEL_FULL_VER | cut -d'.' -f1-2)

# Dracut config
DRACUT_MODULES='lvm dm'
DRACUT_KERNEL_MODULES='efivarfs igb nvme-core nvme nvidia iptable_nat bpfilter team team_mode_broadcast team_mode_loadbalance team_mode_roundrobin snd-mixer-oss snd-pcm-oss snd-seq-oss snd-seq-midi-event snd-seq snd-hrtimer snd-hwdep snd-pcm snd-rawmidi snd-seq-device snd-timer snd snd-hda-ext-core snd-hda-core snd-usb-audio snd-usbmidi-lib snd-hda-codec-generic snd-hda-intel snd-usb-audio snd-hda-codec-hdmi snd-hda-codec-ca0132'

#- System options -#
# This section is BETA.
OS_INPUT="libinput joystick mouse"  # needs to be hardcoded
OS_GUI="kde"                        # unused currently
OS_BOOT_TYPE="grub"                 # unused currently
# You must escape variables in this var due to how variable expansion works in bash
OS_GLOBAL_USE='\${ARCH} X posix nptl smp avahi curl ipv6 acpi hddtemp libnotify lm_sensors pam readline syslog unicode usb openssl alsa kde pm-utils dbus policykit udisks lvm ffmpeg opus gstreamer gles egl vdpau nvidia opencv uvm gtk3 cron wayland 7zip python java ruby networkmanager pulseaudio v4l vaapi x265 theora zeroconf samba cgroups AArch64 -gnome -static -systemd -bindist -handbook -pulseaudio'

#- Internal script settings -#
# Do not change these
TEXT_BOLD=$(tput bold)
TEXT_NORMAL=$(tput sgr0)
TEXT_ERROR=$(tput setaf 1)
TEXT_WARNING=$(tput setaf 3)
TEXT_OK=$(tput setaf 6)
