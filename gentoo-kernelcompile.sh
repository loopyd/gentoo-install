#!/bin/bash

echo 'Enabling efivarfs...'
umount -v efivarfs && mount -v efivarfs

# Compile kernel
echo 'Compiling kernel...'
cd /usr/src/linux
make clean && make mrproper defconfig && make prepare

# Automatic configurationso for gentoo pulled from this github Gentoo Kernel Guide page
# https://github.com/gg7/gentoo-kernel-guide
#
# /proc/config.gz
./scripts/config --enable IKCONFIG      # tristate
./scripts/config --enable IKCONFIG_PROC # boolean

# gentoo-sources ( https://gitweb.gentoo.org/proj/linux-patches.git/tree/4567_distro-Gentoo-Kconfig.patch ):
./scripts/config --enable DEVTMPFS # boolean
./scripts/config --enable TMPFS    # boolean
./scripts/config --enable UNIX     # tristate
./scripts/config --enable SHMEM    # boolean

# gentoo/portage:
./scripts/config --enable CGROUPS    # boolean
./scripts/config --enable NAMESPACES # boolean
./scripts/config --enable IPC_NS     # boolean
./scripts/config --enable NET_NS     # boolean
./scripts/config --enable SYSVIPC    # boolean

# openrc/runit support
./scripts/config --enable BINFMT_SCRIPT # tristate

# Recommended by the Gentoo Handbook: "Also select Maintain a devtmpfs file
# system to mount at /dev so that critical device files are already available
# early in the boot process (CONFIG_DEVTMPFS and DEVTMPFS_MOUNT)":
./scripts/config --enable DEVTMPFS       # boolean
./scripts/config --enable DEVTMPFS_MOUNT # boolean

# required for CHECKPOINT_RESTORE
./scripts/config --enable EXPERT # boolean

# systemd -- gentoo ebuild:
./scripts/config --enable AUTOFS4_FS           # tristate
./scripts/config --enable BLK_DEV_BSG          # boolean
./scripts/config --enable CGROUPS              # boolean
./scripts/config --enable CHECKPOINT_RESTORE   # boolean
./scripts/config --enable CRYPTO_HMAC          # tristate
./scripts/config --enable CRYPTO_SHA256        # tristate
./scripts/config --enable CRYPTO_USER_API_HASH # tristate
# ./scripts/config --enable DEVPTS_MULTIPLE_INSTANCES # removed -- https://github.com/torvalds/linux/commit/eedf265aa003
./scripts/config --enable DMIID                # boolean
./scripts/config --enable EPOLL                # boolean
./scripts/config --enable FANOTIFY             # boolean
./scripts/config --enable FHANDLE              # boolean
./scripts/config --enable INOTIFY_USER         # boolean
./scripts/config --enable IPV6                 # tristate
./scripts/config --enable NET                  # boolean
./scripts/config --enable NET_NS               # boolean
./scripts/config --enable PROC_FS              # boolean
./scripts/config --enable SECCOMP              # boolean
./scripts/config --enable SECCOMP_FILTER       # boolean
./scripts/config --enable SIGNALFD             # boolean
./scripts/config --enable SYSFS                # boolean
./scripts/config --enable TIMERFD              # boolean
./scripts/config --enable TMPFS_POSIX_ACL      # boolean
./scripts/config --enable TMPFS_XATTR          # boolean
./scripts/config --enable ANON_INODES          # boolean
./scripts/config --enable BLOCK                # boolean
./scripts/config --enable EVENTFD              # boolean
./scripts/config --enable FSNOTIFY             # boolean
./scripts/config --enable INET                 # boolean
./scripts/config --enable NLATTR               # boolean

# systemd -- extra things from https://cgit.freedesktop.org/systemd/systemd/tree/README
./scripts/config --enable DEVTMPFS               # boolean
./scripts/config --disable SYSFS_DEPRECATED      # boolean
./scripts/config --set-str UEVENT_HELPER_PATH ""
./scripts/config --disable FW_LOADER_USER_HELPER # boolean
./scripts/config --enable EXT4_FS_POSIX_ACL      # boolean
./scripts/config --enable BTRFS_FS_POSIX_ACL     # boolean
./scripts/config --enable CGROUP_SCHED           # boolean
./scripts/config --enable FAIR_GROUP_SCHED       # boolean
./scripts/config --enable CFS_BANDWIDTH          # boolean
./scripts/config --enable SCHEDSTATS             # boolean
./scripts/config --enable SCHED_DEBUG            # boolean
./scripts/config --enable EFIVAR_FS              # tristate
./scripts/config --enable EFI_PARTITION          # boolean
# ./scripts/config --disable RT_GROUP_SCHED      # boolean, docker wants this
# ./scripts/config --disable AUDIT               # boolean, conflicts with consolekit

# chromium
./scripts/config --enable PID_NS          # boolean
./scripts/config --enable NET_NS          # boolean
./scripts/config --enable SECCOMP_FILTER  # boolean
./scripts/config --enable USER_NS         # boolean
./scripts/config --enable ADVISE_SYSCALLS # boolean
./scripts/config --disable COMPAT_VDSO    # boolean

# qemu for kernel dev
./scripts/config --module VIRTIO_PCI    # tristate
./scripts/config --module VIRTIO_BLK    # tristate
./scripts/config --module VIRTIO_NET    # tristate
./scripts/config --module 9P_FS         # tristate
./scripts/config --module NET_9P        # tristate
./scripts/config --module NET_9P_VIRTIO # tristate

# lm_sensors
./scripts/config --enable I2C_CHARDEV # tristate

# cryptsetup, luks (according to gentoo wiki page)
./scripts/config --enable BLK_DEV_DM               # tristate
./scripts/config --enable DM_CRYPT                 # tristate
./scripts/config --enable CRYPTO_AES_X86_64        # tristate
./scripts/config --enable CRYPTO_XTS               # tristate
./scripts/config --enable CRYPTO_SHA256            # tristate
./scripts/config --enable CRYPTO_USER_API_SKCIPHER # tristate

# openvpn
./scripts/config --module TUN # tristate

# cups
./scripts/config --module USB_PRINTER # tristate

# pulseaudio
./scripts/config --set-val SND_HDA_PREALLOC_SIZE 2048

# Docker (useful: contrib/check-config.sh)
# "Generally Necessary"
./scripts/config --enable NAMESPACES                   # boolean
./scripts/config --enable NET_NS                       # boolean
./scripts/config --enable PID_NS                       # boolean
./scripts/config --enable IPC_NS                       # boolean
./scripts/config --enable UTS_NS                       # boolean
./scripts/config --enable CGROUPS                      # boolean
./scripts/config --enable CGROUP_CPUACCT               # boolean
./scripts/config --enable CGROUP_DEVICE                # boolean
./scripts/config --enable CGROUP_FREEZER               # boolean
./scripts/config --enable CGROUP_SCHED                 # boolean
./scripts/config --enable CPUSETS                      # boolean
./scripts/config --enable MEMCG                        # boolean
./scripts/config --enable KEYS                         # boolean
./scripts/config --module VETH                         # tristate
./scripts/config --module BRIDGE                       # tristate
./scripts/config --module NETFILTER_ADVANCED           # boolean, implicit requirement for BRIDGE_NETFILTER
./scripts/config --module BRIDGE_NETFILTER             # tristate
./scripts/config --module NF_NAT_IPV4                  # tristate
./scripts/config --module IP_NF_FILTER                 # tristate
./scripts/config --module IP_NF_TARGET_MASQUERADE      # tristate
./scripts/config --module NETFILTER_XT_MATCH_ADDRTYPE  # tristate
./scripts/config --module NETFILTER_XT_MATCH_CONNTRACK # tristate
./scripts/config --module NETFILTER_XT_MATCH_IPVS      # tristate
./scripts/config --module IP_NF_NAT                    # tristate
./scripts/config --module NF_NAT                       # tristate
./scripts/config --enable NF_NAT_NEEDED                # boolean
./scripts/config --enable POSIX_MQUEUE                 # boolean
# "Optional Features"
./scripts/config --enable USER_NS                      # boolean
./scripts/config --enable SECCOMP                      # boolean
./scripts/config --enable CGROUP_PIDS                  # boolean
./scripts/config --enable MEMCG_SWAP                   # boolean
./scripts/config --enable MEMCG_SWAP_ENABLED           # boolean
./scripts/config --enable LEGACY_VSYSCALL_EMULATE      # boolean
./scripts/config --enable BLK_CGROUP                   # boolean
./scripts/config --enable BLK_DEV_THROTTLING           # boolean
./scripts/config --module IOSCHED_CFQ                  # tristate
./scripts/config --enable CFQ_GROUP_IOSCHED            # boolean
./scripts/config --enable CGROUP_PERF                  # boolean
./scripts/config --enable CGROUP_HUGETLB               # boolean
./scripts/config --module NET_CLS_CGROUP               # tristate
./scripts/config --enable CGROUP_NET_PRIO              # boolean
./scripts/config --enable CFS_BANDWIDTH                # boolean
./scripts/config --enable FAIR_GROUP_SCHED             # boolean
./scripts/config --enable RT_GROUP_SCHED               # boolean
./scripts/config --module IP_VS                        # tristate
./scripts/config --enable IP_VS_NFCT                   # boolean
./scripts/config --module IP_VS_RR                     # tristate
./scripts/config --enable EXT4_FS                      # tristate
./scripts/config --enable EXT4_FS_POSIX_ACL            # boolean
./scripts/config --enable EXT4_FS_SECURITY             # boolean
# "Network Drivers/overlay"
./scripts/config --module VXLAN                        # tristate
# "Network Drivers/overlay/Optional (for encrypted networks)":
./scripts/config --enable CRYPTO                       # tristate
./scripts/config --enable CRYPTO_AEAD                  # tristate
./scripts/config --enable CRYPTO_GCM                   # tristate
./scripts/config --enable CRYPTO_SEQIV                 # tristate
./scripts/config --enable CRYPTO_GHASH                 # tristate
./scripts/config --enable XFRM                         # boolean
./scripts/config --enable XFRM_USER                    # tristate
./scripts/config --enable XFRM_ALGO                    # tristate
./scripts/config --module INET_ESP                     # tristate
./scripts/config --enable INET_XFRM_MODE_TRANSPORT     # tristate
# "Network Drivers/ipvlan"
./scripts/config --enable NET_L3_MASTER_DEV            # boolean, required for IPVLAN
./scripts/config --module IPVLAN                       # tristate
# macvlan
./scripts/config --module MACVLAN                      # tristate
./scripts/config --module DUMMY                        # tristate
# "ftp,tftp client in container"
# ./scripts/config --module NF_NAT_FTP                   # tristate
# ./scripts/config --module NF_CONNTRACK_FTP             # tristate
# ./scripts/config --module NF_NAT_TFTP                  # tristate
# ./scripts/config --module NF_CONNTRACK_TFTP            # tristate
# "Storage Drivers"
./scripts/config --enable BTRFS_FS                     # tristate
./scripts/config --enable BTRFS_FS_POSIX_ACL           # boolean
./scripts/config --enable BLK_DEV_DM                   # tristate
./scripts/config --enable DM_THIN_PROVISIONING         # tristate
./scripts/config --module OVERLAY_FS                   # tristate
# From the gentoo ebuild
./scripts/config --enable SYSVIPC                      # boolean
./scripts/config --enable IP_VS_PROTO_TCP              # boolean
./scripts/config --enable IP_VS_PROTO_UDP              # boolean

# libvirt
./scripts/config --module MACVTAP # tristate

# sys-auth/consolekit-1.1.2
./scripts/config --enable AUDIT        # boolean, required for AUDITSYSCALL
./scripts/config --enable AUDITSYSCALL # boolean

# SCSI disk support
./scripts/config --enable BLK_DEV_SD # tristate

./scripts/config --enable  EXT2_FS     # tristate
./scripts/config --disable EXT3_FS     # tristate, "This config option is here only for backward compatibility. ext3 filesystem is now handled by the ext4 driver"
./scripts/config --enable  EXT4_FS     # tristate
./scripts/config --enable  VFAT_FS     # tristate
./scripts/config --module  REISERFS_FS # tristate
./scripts/config --enable  XFS_FS      # tristate
./scripts/config --enable  BTRFS_FS    # tristate
./scripts/config --enable  FUSE_FS     # tristate
./scripts/config --enable  ISO9660_FS  # tristate
./scripts/config --enable  PROC_FS     # boolean
./scripts/config --enable  TMPFS       # boolean

# USB input devices
./scripts/config --enable HID_GENERIC  # tristate
./scripts/config --enable USB_HID      # tristate
./scripts/config --enable USB_SUPPORT  # boolean
./scripts/config --enable USB_XHCI_HCD # tristate
./scripts/config --enable USB_EHCI_HCD # tristate
./scripts/config --enable USB_OHCI_HCD # tristate
./scripts/config --enable USB_UAS      # tristate, "USB attached SCSI"

# support 32-bit executables
./scripts/config --enable IA32_EMULATION # boolean

# GPT, EFI, UEFI
./scripts/config --enable  PARTITION_ADVANCED # boolean
./scripts/config --enable  EFI_PARTITION      # boolean
./scripts/config --enable  EFI                # boolean
./scripts/config --enable  EFI_STUB           # boolean
./scripts/config --enable  EFI_MIXED          # boolean
./scripts/config --enable  EFI_VARS           # tristate
./scripts/config --disable OSF_PARTITION      # boolean, Alpha servers
./scripts/config --disable AMIGA_PARTITION    # boolean
./scripts/config --disable SGI_PARTITION      # boolean
./scripts/config --disable SUN_PARTITION      # boolean
./scripts/config --disable KARMA_PARTITION    # boolean
./scripts/config --enable  MAC_PARTITION      # boolean

./scripts/config --enable MAGIC_SYSRQ # boolean

# app-emulation/qemu
./scripts/config --module KVM       # tristate
./scripts/config --module VHOST_NET # tristate

# https://lwn.net/Articles/680989/
# https://lwn.net/Articles/681763/
./scripts/config --enable BLK_WBT    # boolean
./scripts/config --enable BLK_WBT_SQ # boolean
./scripts/config --enable BLK_WBT_MQ # boolean

# http://algo.ing.unimo.it/people/paolo/disk_sched/
./scripts/config --module IOSCHED_BFQ # tristate

# https://www.youtube.com/watch?v=y5KPryOHwk8
# https://en.wikipedia.org/wiki/Active_queue_management
# https://lwn.net/Articles/616241/
./scripts/config --enable NET_SCHED        # boolean
./scripts/config --module IFB              # tristate
./scripts/config --module NET_SCH_HTB      # tristate
./scripts/config --module NET_SCH_CBQ      # tristate
./scripts/config --module NET_SCH_HFSC     # tristate
./scripts/config --module NET_SCH_FQ       # tristate
./scripts/config --module NET_SCH_FQ_CODEL # tristate
./scripts/config --module NET_SCH_SFB      # tristate
./scripts/config --module NET_SCH_INGRESS  # tristate
./scripts/config --module NET_CLS_U32      # tristate

# https://lwn.net/Articles/758353/
./scripts/config --module NET_SCH_CAKE # tristate
./scripts/config --module NET_ACT_MIRRED # tristate
./scripts/config --module NET_SCH_PIE # tristate

# https://news.ycombinator.com/item?id=14813723
./scripts/config --module TCP_CONG_BBR # tristate

# IP ECMP
./scripts/config --enable IP_ROUTE_MULTIPATH # boolean

# source-based IP routing
./scripts/config --enable IP_MULTIPLE_TABLES # boolean

# bridging
./scripts/config --module BRIDGE # tristate
# multicast
./scripts/config --enable BRIDGE_IGMP_SNOOPING # boolean

# speed up tcpdump
./scripts/config --enable BPF_JIT # boolean

# timing packets / ptp (Precision Time Protocol)
./scripts/config --enable NETWORK_PHY_TIMESTAMPING # boolean

./scripts/config --module IP_VS   # tristate
./scripts/config --module BONDING # tristate

# boot_delay=X support
./scripts/config --enable BOOT_PRINTK_DELAY # boolean

# thp, compaction
./scripts/config --enable TRANSPARENT_HUGEPAGE
./scripts/config --enable TRANSPARENT_HUGEPAGE_ALWAYS

# dev-util/bcc
./scripts/config --enable BPF_SYSCALL     # boolean
./scripts/config --module NET_CLS_BPF     # tristate
./scripts/config --module NET_ACT_BPF     # tristate
./scripts/config --enable BPF_EVENTS      # boolean
./scripts/config --enable DEBUG_INFO      # boolean
./scripts/config --enable FUNCTION_TRACER # boolean
./scripts/config --enable KALLSYMS_ALL    # boolean

# https://lwn.net/Articles/759781/
./scripts/config --enable PSI # bool
./scripts/config --enable PSI_DEFAULT_DISABLED # bool

# https://www.phoronix.com/scan.php?page=article&item=linux_2637_video&num=1
./scripts/config --enable SCHED_AUTOGROUP # boolean

# Inject running kernel modules from liveCD.
make localmodconfig

# Some tweaks will be required, not unattended, but you know, for the sake
# of completeness, lets let the user make the tweaks they want.
make nconfig
make -j7
make modules_install && make install
cd ~

VIDEO_DEVIES=$(/root/gentoo-hardwarehelper.sh "gpu_vendors")
case "$VIDEO_DEVIES" in
	*nvidia*)
		## This is not an indentation error, here documents hate indents as they are
		## taken literally.  May as well just make it consistant.
nvidia-xconfig
eselect opengl set nvidia
eselect opencl set nvidia
		;;
	*amdgpu*)
		## TODO: See docs/AMDUSERS.md for details.
		;;
	*radeonsi*)
		## TODO: See docs/AMDUSERS.md for details.
		;;
	*)
		## TODO: Add more supported GPUs
		;;
esac

echo 'Emerging CPU microcode and firmware packages...'
CPU_VENDOR=$(/root/gentoo-hardwarehelper.sh "gpu_vendors")
case "$CPU_VENDOR" in
	*intel*)
cat <<EOF >>/etc/portage/package.license/sys-firmware
sys-firmware/intel-microcode intel-ucode
EOF
emerge --deep sys-firmware/intel-microcode
		;;
	*amd*)
		## No need, included in sys-firmware/linux-firmware package.
		;;
	*)
		## TODO: Add more supported CPU vendors.
		;;
esac
emerge --deep linux-firmware

echo 'Compiling initramfs...'
dracut --kver $KERNEL_FULL_VER-$KERNEL_RELEASE_VER -H --add "$DRACUT_MODULES" --add-drivers "$DRACUT_KERNEL_MODULES" -i /lib/firmware /lib/firmware--hostonly-cmdline --fstab --gzip --lvmconf --early-microcode --force /boot/initramfs-$KERNEL_FULL_VER-$KERNEL_RELEASE_VER.img

echo 'Configuring grub...'
cat <<EOF > /etc/default/grub
GRUB_DISTRIBUTOR="Gentoo"
GRUB_CMDLINE_LINUX="rd.auto=1 scsi_mod.use_blk_mq=1"
EOF

echo 'Installing grub...'
grub-install $OS_DEVICE --efi-directory=/boot/efi --target=x86_64-efi --no-floppy
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Configuring bfq scheduler udev rules...'
cat <<EOF > /etc/udev/rules.d/60-scheduler.rules
ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="bfq"
EOF

#- ENABLE SERVICES -#
# Without configuring these to start, we won't get past login
# I went through a broken system's dmesg | grep for a little
# while to get this list of needy, red headed stepchildren.
#
rc-update add lvm boot
rc-update add mdraid boot
rc-update add multipath boot
rc-update add alsasound boot
rc-update add dbus boot
rc-update add syslog-ng default 
rc-update add cronie default
rc-update add acpid default
rc-update add NetworkManager default
rc-update add sshd default
rc-update add bootchart2 default
rc-update add nfsmount default
rc-update add nfsclient default
rc-update add netmount default
rc-update add consolekit default