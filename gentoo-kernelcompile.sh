#!/bin/bash

echo -ne "${TEXT_BOLD}Compiling kernel${TEXT_NORMAL}\n\n    This process can take a long time depending on the speed of your CPU.\n    Grab a cup of coffee or something!\n\n\n"
echo -ne "\033[1A    [${TEXT_BOLD}prep${TEXT_NORMAL}] "

#- Remount efivarfs -#
echo -ne "${TEXT_WARNING}efi${TEXT_NORMAL}"
## umount -v efivarfs && mount -v efivarfs
echo -ne "\033[3D${TEXT_OK}efi${TEXT_NORMAL} "

emerge_wrapper -C dev-libs/openssl-1.0.2t-r1
flaggie_wrapper sys-libs/ncurses -gpm
flaggie_wrapper sys-libs/pam -filecaps
flaggie_wrapper sys-fs/eudev -introspection
flaggie_wrapper sys-boot/grub:2 +mount +device-mapper +truetype +fonts
flaggie_wrapper media-plugins/alsa-plugins +pulseaudio
flaggie_wrapper \>=dev-lang/python-2.7.15 +sqlite
flaggie_wrapper app-benchmarks/bootchart2 +~amd64
flaggie_wrapper x11-drivers/nvidia-drivers +NVIDIA-r2
flaggie_wrapper sys-firmware/intel-microcode +intel-ucode
flaggie_wrapper =sys-kernel/$KERNEL_RELEASE_VER-sources-$KERNEL_FULL_VER +~amd64
flaggie_wrapper =sys-kernel/linux-headers-$KERNEL_MINOR_VER +~amd64
etc_update_wrapper

emerge_wrapper --with-bdeps=y =sys-kernel/$KERNEL_RELEASE_VER-sources-$KERNEL_FULL_VER =sys-kernel/linux-headers-$KERNEL_MINOR_VER
# Compile kernel
cd /usr/src/linux
echo -ne "\033[2K\033[200D    [${TEXT_BOLD}make${TEXT_NORMAL}] "

kernel_wrapper 'clean'
kernel_wrapper 'mrproper'
kernel_wrapper 'defconfig'

echo -ne "${TEXT_WARNING}s${TEXT_NORMAL}"
./scripts/config --disable ACPI_AC
./scripts/config --disable ACPI_BATTERY
./scripts/config --disable ACPI_DOCK
./scripts/config --disable AMD_NUMA
./scripts/config --disable AMIGA_PARTITION
./scripts/config --disable COMPAT_VDSO
./scripts/config --disable BPF_JIT_ALWAYS_ON
./scripts/config --disable CPU_SUP_AMD
./scripts/config --disable CPU_SUP_CENTAUR
./scripts/config --disable CPU_SUP_HYGON
./scripts/config --disable CPU_SUP_ZHAOXIN
./scripts/config --disable DEBUG_RSEQ
./scripts/config --disable FW_LOADER_USER_HELPER
./scripts/config --disable KARMA_PARTITION
./scripts/config --disable MACINTOSH_DRIVERS
./scripts/config --disable MICROCODE_AMD
./scripts/config --disable OSF_PARTITION
./scripts/config --disable PC104
./scripts/config --disable PREEMPT_NONE
./scripts/config --disable PREEMPT_VOLUNTARY
./scripts/config --disable SGI_PARTITION
./scripts/config --disable SUN_PARTITION
./scripts/config --disable SYSFS_DEPRECATED
./scripts/config --disable X86_EXTENDED_PLATFORM
./scripts/config --enable ACPI_APEI
./scripts/config --enable ACPI_APEI_PCIEAER
./scripts/config --enable ACPI_BGRT
./scripts/config --enable ACPI_CONFIGFS
./scripts/config --enable ACPI_HMAT
./scripts/config --enable ACPI_NFIT
./scripts/config --enable ACPI_PCI_SLOT
./scripts/config --enable ADVISE_SYSCALLS
./scripts/config --enable ANON_INODES
./scripts/config --enable ASYNC_CORE
./scripts/config --enable ASYNC_MEMCPY
./scripts/config --enable ASYNC_PQ
./scripts/config --enable ASYNC_RAID6_RECOV
./scripts/config --enable ASYNC_XOR
./scripts/config --enable AUDIT
./scripts/config --enable AUDITSYSCALL
./scripts/config --enable AUTOFS4_FS
./scripts/config --enable BFQ_GROUP_IOSCHED
./scripts/config --enable BINFMT_SCRIPT
./scripts/config --enable BLK_CGROUP
./scripts/config --enable BLK_DEV_BSG
./scripts/config --enable BLK_DEV_DM
./scripts/config --enable BLK_DEV_SD
./scripts/config --enable BLK_DEV_THROTTLING
./scripts/config --enable BLK_WBT
./scripts/config --enable BLK_WBT_MQ
./scripts/config --enable BLK_WBT_SQ
./scripts/config --enable BLOCK
./scripts/config --enable BOOT_PRINTK_DELAY
./scripts/config --enable BPF_EVENTS
./scripts/config --enable BPF_JIT
./scripts/config --enable BPF_SYSCALL
./scripts/config --enable BRIDGE_IGMP_SNOOPING
./scripts/config --enable BTRFS_FS
./scripts/config --enable BTRFS_FS_POSIX_ACL
./scripts/config --enable CFQ_GROUP_IOSCHED
./scripts/config --enable CFS_BANDWIDTH
./scripts/config --enable CGROUPS
./scripts/config --enable CGROUP_BPF
./scripts/config --enable CGROUP_CPUACCT
./scripts/config --enable CGROUP_DEVICE
./scripts/config --enable CGROUP_FREEZER
./scripts/config --enable CGROUP_HUGETLB
./scripts/config --enable CGROUP_NET_PRIO
./scripts/config --enable CGROUP_PERF
./scripts/config --enable CGROUP_PIDS
./scripts/config --enable CGROUP_SCHED
./scripts/config --enable CHECKPOINT_RESTORE
./scripts/config --enable CPUSETS
./scripts/config --enable CPU_FREQ_STAT
./scripts/config --enable CPU_SUP_INTEL
./scripts/config --enable CRYPTO
./scripts/config --enable CRYPTO_AEAD
./scripts/config --enable CRYPTO_AES_NI_INTEL
./scripts/config --enable CRYPTO_AES_X86_64
./scripts/config --enable CRYPTO_CRC32C_INTEL
./scripts/config --enable CRYPTO_CRC32_PCLMUL
./scripts/config --enable CRYPTO_CRCT10DIF_PCLMUL
./scripts/config --enable CRYPTO_CRYPTD
./scripts/config --enable CRYPTO_DH
./scripts/config --enable CRYPTO_GCM
./scripts/config --enable CRYPTO_GHASH
./scripts/config --enable CRYPTO_GHASH_CLMUL_NI_INTEL
./scripts/config --enable CRYPTO_GLUE_HELPER_X86
./scripts/config --enable CRYPTO_GLUE_HELPER_X86
./scripts/config --enable CRYPTO_HMAC
./scripts/config --enable CRYPTO_LRW
./scripts/config --enable CRYPTO_PCRYPT
./scripts/config --enable CRYPTO_SEQIV
./scripts/config --enable CRYPTO_SHA256
./scripts/config --enable CRYPTO_SHA512
./scripts/config --enable CRYPTO_USER_API_HASH
./scripts/config --enable CRYPTO_USER_API_RNG
./scripts/config --enable CRYPTO_USER_API_SKCIPHER
./scripts/config --enable CRYPTO_WP512
./scripts/config --enable CRYPTO_XTS
./scripts/config --enable DCA
./scripts/config --enable DEBUG_INFO
./scripts/config --enable DEVTMPFS
./scripts/config --enable DEVTMPFS_MOUNT
./scripts/config --enable DMIID
./scripts/config --enable DM_BUFIO
./scripts/config --enable DM_CRYPT
./scripts/config --enable DM_THIN_PROVISIONING
./scripts/config --enable DRM_TTM
./scripts/config --enable EFI
./scripts/config --enable EFIVAR_FS
./scripts/config --enable EFI_MIXED
./scripts/config --enable EFI_PARTITION
./scripts/config --enable EFI_STUB
./scripts/config --enable EFI_VARS
./scripts/config --enable ENERGY_MODEL
./scripts/config --enable EPOLL
./scripts/config --enable EVENTFD
./scripts/config --enable EXPERT
./scripts/config --enable EXT2_FS
./scripts/config --enable EXT2_FS_POSIX_ACL
./scripts/config --enable EXT2_FS_SECURITY
./scripts/config --enable EXT4_FS
./scripts/config --enable EXT4_FS_POSIX_ACL
./scripts/config --enable EXT4_FS_SECURITY
./scripts/config --enable FAIR_GROUP_SCHED
./scripts/config --enable FANOTIFY
./scripts/config --enable FHANDLE
./scripts/config --enable FSNOTIFY
./scripts/config --enable FUNCTION_TRACER
./scripts/config --enable FUSE_FS
./scripts/config --enable GENTOO_LINUX
./scripts/config --enable GENTOO_LINUX_INIT_SCRIPT
./scripts/config --enable GENTOO_LINUX_INIT_SYSTEMD
./scripts/config --enable GENTOO_LINUX_PORTAGE
./scripts/config --enable GENTOO_LINUX_UDEV
./scripts/config --enable HDA_CODEC_CA0132_DSP
./scripts/config --enable HIBERNATION
./scripts/config --enable HID_GENERIC
./scripts/config --enable I2C_CHARDEV
./scripts/config --enable IA32_EMULATION
./scripts/config --enable IKCONFIG
./scripts/config --enable IKCONFIG_PROC
./scripts/config --enable INET
./scripts/config --enable INET_XFRM_MODE_TRANSPORT
./scripts/config --enable INOTIFY_USER
./scripts/config --enable INTEL_IDLE
./scripts/config --enable INTEL_POWERCLAMP
./scripts/config --enable IOSCHED_BFQ
./scripts/config --enable IPC_NS
./scripts/config --enable IPV6
./scripts/config --enable IP_MULTIPLE_TABLES
./scripts/config --enable IP_ROUTE_MULTIPATH
./scripts/config --enable IP_VS_NFCT
./scripts/config --enable IP_VS_PROTO_TCP
./scripts/config --enable IP_VS_PROTO_UDP
./scripts/config --enable IRQ_BYPASS_MANAGER
./scripts/config --enable ISO9660_FS
./scripts/config --enable KALLSYMS_ALL
./scripts/config --enable KEYS
./scripts/config --enable KVM
./scripts/config --enable KVM_GUEST
./scripts/config --enable KVM_INTEL
./scripts/config --enable MAC_PARTITION
./scripts/config --enable MAGIC_SYSRQ
./scripts/config --enable MEMCG
./scripts/config --enable MEMCG_SWAP
./scripts/config --enable MEMCG_SWAP_ENABLED
./scripts/config --enable MICROCODE_INTEL
./scripts/config --enable MMU
./scripts/config --enable MTRR_SANITIZER
./scripts/config --enable NAMESPACES
./scripts/config --enable NET
./scripts/config --enable NETFILTER_ADVANCED
./scripts/config --enable NETWORK_PHY_TIMESTAMPING
./scripts/config --enable NET_L3_MASTER_DEV
./scripts/config --enable NET_NS
./scripts/config --enable NET_SCHED
./scripts/config --enable NF_NAT_NEEDED
./scripts/config --enable NLATTR
./scripts/config --enable PARTITION_ADVANCED
./scripts/config --enable PID_NS
./scripts/config --enable PMIC_OPREGION
./scripts/config --enable PM_AUTOSLEEP
./scripts/config --enable PM_WAKELOCKS
./scripts/config --enable POSIX_MQUEUE
./scripts/config --enable PREEMPT
./scripts/config --enable PROCESSOR_SELECT
./scripts/config --enable PROC_FS
./scripts/config --enable PSI
./scripts/config --enable PSI_DEFAULT_DISABLED
./scripts/config --enable RAID6_PQ
./scripts/config --enable RTC_CLASS
./scripts/config --enable RTC_DRV_CMOS
./scripts/config --enable RTC_HCTOSYS
./scripts/config --enable RTC_INTF_DEV
./scripts/config --enable RTC_INTF_PROC
./scripts/config --enable RTC_INTF_SYSFS
./scripts/config --enable RTC_SYSTOHC
./scripts/config --enable RT_GROUP_SCHED
./scripts/config --enable SCHEDSTATS
./scripts/config --enable SCHED_AUTOGROUP
./scripts/config --enable SCHED_DEBUG
./scripts/config --enable SECCOMP
./scripts/config --enable SECCOMP_FILTER
./scripts/config --enable SENSORS_CORETEMP
./scripts/config --enable SHMEM
./scripts/config --enable SLAB
./scripts/config --enable SIGNALFD
./scripts/config --enable SUSPEND
./scripts/config --enable SYSCTL_SYSCALL
./scripts/config --enable SYSFS
./scripts/config --enable SYSVIPC
./scripts/config --enable TIMERFD
./scripts/config --enable TMPFS
./scripts/config --enable TMPFS_POSIX_ACL
./scripts/config --enable TMPFS_XATTR
./scripts/config --enable TRANSPARENT_HUGEPAGE
./scripts/config --enable TRANSPARENT_HUGEPAGE_ALWAYS
./scripts/config --enable UNIX
./scripts/config --enable USB_EHCI_HCD
./scripts/config --enable USB_HID
./scripts/config --enable USB_OHCI_HCD
./scripts/config --enable USB_SUPPORT
./scripts/config --enable USB_UAS
./scripts/config --enable USB_XHCI_HCD
./scripts/config --enable USER_NS
./scripts/config --enable UTS_NS
./scripts/config --enable VFAT_FS
./scripts/config --enable VIRTIO_BLK
./scripts/config --enable X86_PCC_CPUFREQ
./scripts/config --enable X86_SYSFB
./scripts/config --enable XFRM
./scripts/config --enable XFRM_ALGO
./scripts/config --enable XFRM_USER
./scripts/config --enable XFS_FS
./scripts/config --enable XFS_FS_POSIX_ACL
./scripts/config --enable XOR_BLOCKS
./scripts/config --module 9P_FS
./scripts/config --module ASYNC_CORE
./scripts/config --module ASYNC_MEMCPY
./scripts/config --module ASYNC_PQ
./scripts/config --module ASYNC_RAID6_RECOV
./scripts/config --module ASYNC_XOR
./scripts/config --module ATL1C
./scripts/config --module BE2ISCSI
./scripts/config --module BLK_DEV_3W_XXXX_RAID
./scripts/config --module BLK_DEV_NVME
./scripts/config --module BLK_DEV_SX8
./scripts/config --module BNX2
./scripts/config --module BONDING
./scripts/config --module BRIDGE
./scripts/config --module BRIDGE_NETFILTER
./scripts/config --module BTRFS_FS
./scripts/config --module CRYPTO_AES_X86_64
./scripts/config --module DM_CRYPT
./scripts/config --module DM_RAID
./scripts/config --module DM_SNAPSHOT
./scripts/config --module FUSION_FC
./scripts/config --module FUSION_SAS
./scripts/config --module FUSION_SPI
./scripts/config --module IFB
./scripts/config --module IGB
./scripts/config --module INET_ESP
./scripts/config --module INFINIBAND_ISER
./scripts/config --module INPUT_JOYDEV
./scripts/config --module INPUT_PCSPKR
./scripts/config --module IPVLAN
./scripts/config --module IP_NF_FILTER
./scripts/config --module IP_NF_NAT
./scripts/config --module IP_NF_TARGET_MASQUERADE
./scripts/config --module IP_VS
./scripts/config --module IP_VS_RR
./scripts/config --module ISCSI_TCP
./scripts/config --module KVM_ARM_HOST
./scripts/config --module KVM_BOOK3S_32
./scripts/config --module KVM_BOOK3S_64
./scripts/config --module KVM_E500MC
./scripts/config --module KVM_E500V2
./scripts/config --module MD_LINEAR
./scripts/config --module MD_MULTIPATH
./scripts/config --module MD_RAID0
./scripts/config --module MD_RAID1
./scripts/config --module MD_RAID10
./scripts/config --module MD_RAID456
./scripts/config --module MEGARAID_LEGACY
./scripts/config --module MEGARAID_MAILBOX
./scripts/config --module MEGARAID_MM
./scripts/config --module MEGARAID_SAS
./scripts/config --module MXM_WMI
./scripts/config --module NETFILTER_XT_MATCH_ADDRTYPE
./scripts/config --module NETFILTER_XT_MATCH_CONNTRACK
./scripts/config --module NETFILTER_XT_MATCH_IPVS
./scripts/config --module NET_9P
./scripts/config --module NET_9P_VIRTIO
./scripts/config --module NET_ACT_BPF
./scripts/config --module NET_ACT_MIRRED
./scripts/config --module NET_CLS_BPF
./scripts/config --module NET_CLS_CGROUP
./scripts/config --module NET_CLS_U32
./scripts/config --module NET_SCH_CAKE
./scripts/config --module NET_SCH_CBQ
./scripts/config --module NET_SCH_FQ
./scripts/config --module NET_SCH_FQ_CODEL
./scripts/config --module NET_SCH_HFSC
./scripts/config --module NET_SCH_HTB
./scripts/config --module NET_SCH_INGRESS
./scripts/config --module NET_SCH_PIE
./scripts/config --module NET_SCH_SFB
./scripts/config --module NF_NAT
./scripts/config --module NF_NAT_IPV4
./scripts/config --module PATA_ALI
./scripts/config --module PATA_ARTOP
./scripts/config --module PATA_ATIIXP
./scripts/config --module PATA_CMD64X
./scripts/config --module PATA_EFAR
./scripts/config --module PATA_HPT366
./scripts/config --module PATA_HPT37X
./scripts/config --module PATA_HPT3X2N
./scripts/config --module PATA_HPT3X3
./scripts/config --module PATA_IT8213
./scripts/config --module PATA_IT821X
./scripts/config --module PATA_JMICRON
./scripts/config --module PATA_MARVELL
./scripts/config --module PATA_MPIIX
./scripts/config --module PATA_NETCELL
./scripts/config --module PATA_NS87410
./scripts/config --module PATA_NS87415
./scripts/config --module PATA_PCMCIA
./scripts/config --module PATA_PDC2027X
./scripts/config --module PATA_PDC_OLD
./scripts/config --module PATA_RADISYS
./scripts/config --module PATA_RZ1000
./scripts/config --module PATA_SERVERWORKS
./scripts/config --module PATA_SIL680
./scripts/config --module PATA_SIS
./scripts/config --module PATA_TRIFLEX
./scripts/config --module PATA_VIA
./scripts/config --module PATA_WINBOND
./scripts/config --module PCNET32
./scripts/config --module PDC_ADMA
./scripts/config --module QEDI 
./scripts/config --module RAID6_PQ
./scripts/config --module SATA_INIC162X
./scripts/config --module SATA_MV
./scripts/config --module SATA_NV
./scripts/config --module SATA_PROMISE
./scripts/config --module SATA_QSTOR
./scripts/config --module SATA_SIL
./scripts/config --module SATA_SIL24
./scripts/config --module SATA_SIS
./scripts/config --module SATA_SVW
./scripts/config --module SATA_SX4
./scripts/config --module SATA_ULI
./scripts/config --module SATA_VIA
./scripts/config --module SATA_VITESSE
./scripts/config --module SCSI_3W_9XXX
./scripts/config --module SCSI_3W_SAS
./scripts/config --module SCSI_AACRAID
./scripts/config --module SCSI_ACARD
./scripts/config --module SCSI_ADVANSYS
./scripts/config --module SCSI_AIC79XX
./scripts/config --module SCSI_AIC7XXX
./scripts/config --module SCSI_AIC94XX
./scripts/config --module SCSI_ARCMSR
./scripts/config --module SCSI_BNX2_ISCSI
./scripts/config --module SCSI_BUSLOGIC
./scripts/config --module SCSI_CXGB3_ISCSI
./scripts/config --module SCSI_CXGB3_ISCSI
./scripts/config --module SCSI_CXGB4_ISCSI
./scripts/config --module SCSI_CXGB4_ISCSI
./scripts/config --module SCSI_DC395x
./scripts/config --module SCSI_DMX3191D
./scripts/config --module SCSI_FC_ATTRS
./scripts/config --module SCSI_GDTH
./scripts/config --module SCSI_HPSA
./scripts/config --module SCSI_INITIO
./scripts/config --module SCSI_ISCSI_ATTRS
./scripts/config --module SCSI_LPFC
./scripts/config --module SCSI_QLA_FC
./scripts/config --module SCSI_QLA_ISCSI
./scripts/config --module SCSI_QLOGIC_1280
./scripts/config --module SCSI_SAS_LIBSAS
./scripts/config --module SCSI_SYM53C8XX_2
./scripts/config --module SERIO_RAW
./scripts/config --module SND_HDA_CODEC_CA0132
./scripts/config --module SND_HDA_CODEC_HDMI
./scripts/config --module SND_HDA_GENERIC
./scripts/config --module SND_RAWMIDI
./scripts/config --module SND_USB_AUDIO
./scripts/config --module SND_USB_UA101
./scripts/config --module SND_USB_US122L
./scripts/config --module SND_USB_USX2Y
./scripts/config --module TCP_CONG_BBR
./scripts/config --module TUN
./scripts/config --module USB_PRINTER
./scripts/config --module USB_SL811_HCD
./scripts/config --module VETH
./scripts/config --module VHOST_NET
./scripts/config --module VIRTIO_NET
./scripts/config --module VIRTIO_PCI
./scripts/config --module VMXNET3
./scripts/config --module VXLAN
./scripts/config --set-str PM_STD_PARTITION "$SWAP_MOUNT"
./scripts/config --set-str RTC_HCTOSYS_DEVICE "rtc0"
./scripts/config --set-str UEVENT_HELPER_PATH ""
./scripts/config --set-val MTRR_SANITIZER_ENABLE_DEFAULT 1
./scripts/config --set-val MTRR_SANITIZER_SPARE_REG_NR_DEFAULT 5
./scripts/config --set-val SND_HDA_POWER_SAVE_DEFAULT 60
./scripts/config --set-val SND_HDA_PREALLOC_SIZE 2048
./scripts/config --undefine SLUB

echo -ne "\033[1D${TEXT_OK}s${TEXT_NORMAL} "
kernel_wrapper 'localmodconfig'
kernel_wrapper 'prepare'
kernel_wrapper '-j7'
kernel_wrapper 'modules_install'
kernel_wrapper 'install'
cd ~

emerge_wrapper -C dev-libs/openssl-1.0.2t-r1
emerge_wrapper --update --with-bdeps=y dracut virtual/udev sys-boot/grub:2 lvm2 os-prober sys-apps/pciutils sys-apps/usbutils sys-apps/hwinfo sys-fs/dosfstools xfsprogs e2fsprogs app-shells/gentoo-bashcomp app-benchmarks/bootchart2 app-admin/killproc sys-process/acct sys-fs/btrfs-progs sys-block/open-iscsi sys-fs/mdadm sys-fs/multipath-tools sys-block/nbd net-fs/nfs-utils net-nds/rpcbind app-shells/gentoo-bashcomp sys-fs/udisks x11-base/xorg-drivers x11-base/xorg-server x11-apps/xinit net-misc/x11-ssh-askpass net-misc/networkmanager app-admin/sudo app-admin/syslog-ng app-admin/logrotate sys-process/cronie alsa-utils media-libs/alsa-lib alsa-plugins alsa-tools pulseaudio 

case "$VIDEO_CARDS" in
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

emerge_wrapper --deep sys-firmware/intel-microcode
emerge_wrapper --deep linux-firmware

echo -ne "\033[2K\033[200D    [${TEXT_BOLD}boot${TEXT_NORMAL}] ${TEXT_WARNING}dracut${TEXT_NORMAL}"
dracut --kver $KERNEL_FULL_VER-$KERNEL_RELEASE_VER -H --add "$DRACUT_MODULES" --add-drivers "$DRACUT_KERNEL_MODULES" -i /lib/firmware /lib/firmware--hostonly-cmdline --fstab --gzip --lvmconf --early-microcode --force /boot/initramfs-$KERNEL_FULL_VER-$KERNEL_RELEASE_VER.img >/dev/null 2>&1
echo -ne "\033[6D${TEXT_OK}dracut${TEXT_NORMAL} "

echo -ne "${TEXT_WARNING}grub${TEXT_NORMAL}"
cat <<EOF > /etc/default/grub
GRUB_DISTRIBUTOR="Gentoo"
GRUB_CMDLINE_LINUX="rd.auto=1 scsi_mod.use_blk_mq=1"
EOF

grub-install $OS_DEVICE --efi-directory=/boot/efi --target=x86_64-efi --no-floppy >/dev/null 2>&1
grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1
echo -ne "\033[4D${TEXT_OK}grub${TEXT_NORMAL} "

echo -ne "${TEXT_WARNING}cfg${TEXT_NORMAL}"
cat <<EOF > /etc/udev/rules.d/60-scheduler.rules
ACTION=="add|change", KERNEL=="nvme*|sd*", ATTR{queue/scheduler}="bfq"
EOF
echo -ne "\033[3D${TEXT_OK}cfg${TEXT_NORMAL} "
echo -ne "[${TEXT_BOLD}${TEXT_OK}done${TEXT_NORMAL}]"

timer_kill

echo -ne "\033[2K\033[200D\n\033[2K\033[200D\033[1A    ${TEXT_BOLD}${TEXT_OK}Kernel install finished!${TEXT_NORMAL}]\n\n"
