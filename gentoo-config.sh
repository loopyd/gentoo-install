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
KERNEL_FULL_VER='5.3.0'
KERNEL_MINOR_VER=$(echo -n $KERNEL_FULL_VER | cut -d'.' -f1-2)

# Dracut config
DRACUT_MODULES='lvm dm'
DRACUT_KERNEL_MODULES='igb nvme-core nvme nvidia'

#- System options -#
# This section is BETA.
OS_INPUT="libinput joystick mouse"  # needs to be hardcoded
OS_GUI="kde"                        # unused currently
OS_BOOT_TYPE="grub"                 # unused currently
# You must escape variables in this var due to how variable expansion works in bash
OS_GLOBAL_USE='\${ARCH} X posix nptl smp avahi curl ipv6 acpi hddtemp libnotify lm_sensors pam readline syslog unicode usb alsa kde pm-utils dbus udisks lvm ffmpeg nvidia opencv uvm gtk3 cron 7zip openssl networkmanager samba elogind cgroups AArch64 -gnome -static-libs -systemd -handbook -consolekit -ruby-targets-ruby23 -python-targets-python27'

#- Internal script settings -#
# Do not change these
TEXT_BOLD=$(tput bold)
TEXT_NORMAL=$(tput sgr0)
TEXT_ERROR=$(tput setaf 1)
TEXT_WARNING=$(tput setaf 3)
TEXT_OK=$(tput setaf 6)
