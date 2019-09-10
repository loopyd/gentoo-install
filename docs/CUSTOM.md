# GentoDAD Documentation
## Customization Guide

This script obviously doesn't work with your system.  So some configuration options have been added for you.  The contents of this repository contain a working model for a very particular setup.  To use it for yourself, you will need to customize it.

You'll need to perform the following steps from a working machine:

1.  Clone this repository
2.  Follow the rest of the customization guide to tailer the installer to your system.
3.  Run the script and keep tweaking till it works !

Before the hate mail comes, the fun of Gentoo is tweaking and messing around with Linux.
I have done a lot for you.  The rest is **up to you!**

### Mount and partition sceme

Mount point and partition configurations are provided, but may need some manual editing.
You can find these options in ``gentoo-config.sh``.

> **Note** - Currently, only LVM is supported as a scheme type.  This **will change** as the repository matures.

| Option | Use | Default | Autovar[1]
| --- | --- | --- | --- |
**CHROOT_MOUNT** | Where on the host the chroot will be mounted. | ``/mnt/gentoo`` | No
**HOME_LABEL** | LVM label for the ``/home`` partition. | ``linux_home'`` | No
**ROOT_LABEL** | LVM label for the ``/`` (root) partition. | ``linux_root`` | No
**SWAP_LABEL** | LVM label for the ``swap`` partition. | ``linux_swap`` | No
**VARLOG_LABEL** | LVM label for the ``/var/log`` partition. | ``var_log`` | No
**HOME_MOUNT** | LVM device mountpoint for the ``home`` partition.  | ``/dev/mapper/gentoo-$HOME_LABEL`` | Yes
**ROOT_MOUNT** | LVM device mountpoint for the ``/`` (root) partition. | ``/dev/mapper/gentoo-$ROOT_LABEL`` | Yes
**SWAP_MOUNT** | LVM device mountpoint for the ``swap`` partition. | ``/dev/mapper/gentoo-$SWAP_LABEL`` | Yes
**VARLOG_MOUNT** | LVM device mountpoint fo the ``/var/log`` partition. | ``/dev/mapper/gentoo-$VARLOG_LABEL`` | Yes
**BOOT_DEVICE** | Device path for the ``/boot/efi`` partition. | ``/dev/nvme0n1p1'`` | No
**LVM_DEVICE** | Device path for the LVM physical volume. | ``/dev/nvme0n1p2`` | No
**OS_DEVICE** | Base device path for Gentoo installation | ``/dev/nvme0n1`` | No

[1] Autovars are set automatically by **variable expansion**.  You can modify them as you wish, but you should pay attention to where they are used in scripts to avoid bugs.

### Package configuration

**Editing the injected configuration**
To edit the configuration, edit the here documents ( ``cat<<'EOF'`` ) lines in ``gentoo-injectconfig.sh``

> **Note**: Modifying the here documents that contain variable expansion is touchy.  They look like
> ``cat <<EOFDOC`` or similar (notice the lack of single quotation marks.  These are automatic heredocs
> so do so at your own risk.

### Kernel

To add your own custom kernel configuration, you can make the following changes:

1.  Replace the contents of kernel-config.txt with your own.
2.  Edit the values in ``gentoo-config.sh`` according to the following table:

| Option | Use | Default | Autovar[5]
| --- | --- | --- | --- |
**KERNEL_RELEASE_VER** | Set to the name of the kernel release. | gentoo | No
**KERNEL_FULL_VER** | Set to the full version of the kernel release you would like to install. | 5.2.8 | No
**KERNEL_MINOR_VER** | Do not change this line.  It is automatic. | code | Yes

[5] Autovars are set automatically by code and should not be changed.

> **NOTE**: This script does no sanity checking whatsover, please make sure that your kernel compiles without
> help first !

### Dracut Initramfs

You can modify ``gentoo-config.sh`` underneath the initramfs section accordingly to load the kernel modules you need.

| Option | Use | Default | Autovar[2]
| --- | --- | --- | --- |
**DRACUT_MODULES** | Dracut modules which should load in addition to your host's configuration. | ``lvm dm`` | No
**DRACUT_KERNEL_MODULES** | Modules from your kernel which should load accordingly. | ``efivarfs igb bluetooth nvme-core nvme nvidia thunderbolt-net iptable_nat bpfilter team team_mode_broadcast team_mode_loadbalance team_mode_roundrobin vfio vfio_iommu_type1 vfio-pci`` | No

[2] Autovars are set automatically by **variable expansion**.  You can modify them as you wish, but you should pay attention to where they are used in scripts to avoid bugs.

### Locale

You can customize your system language by editing the locale configuration options in ``gentoo-config.sh``:

| Option | Use | Default | Autovar[3]
| --- | --- | --- | --- |
**DEFAULT_LOCALE** | Default language for your system. | ``en_US.UTF-8`` | No
**LOCALES_TOGEN** | List of locales to generate. | ``en_US ISO-8859-1``<br/>``en_US.UTF-8 UTF-8`` | No
**TIMEZONE** | Default Timezone for the system clock. | ``America/New_York`` | No

[3] Autovars are set automatically by **variable expansion**.  You can modify them as you wish, but you should pay attention to where they are used in scripts to avoid bugs.

### Network

You can custimze some of the script's network configuration using these options.

**UPDATE:** Due to the use of NetworkManager in future iterations of GentooDAD, dhclient is used and sets up networking automatically using a DHCP server.  You no longer have to worry about configuring most settings here.

| Option | Use | Default | Autovar[4]
| --- | --- | --- | --- |
**DNS1_ADDRESS** | Primary DNS server | ``8.8.8.8`` | No
**DNS2_ADDRESS** | Secondary DNS server | ``8.8.4.4`` | No

[4] Autovars are set automatically by **variable expansion**.  You can modify them as you wish, but you should pay attention to where they are used in scripts to avoid bugs.

### Account Credentials

You can change some details of the default user account that is created during the installation, as well as those for the root user.

| Option | Use | Default | Autovar[3]
| --- | --- | --- | --- |
**USERNAME** | Default user account name | ``heavypaws`` | Yes
**PASSWORD** | Default user account password | ``p4ssw0rd`` | Yes
**ROOT_PASSWORD** | Default root password | ``p4ssw0rd`` | Yes

[2] Autovars are set automatically by **variable expansion**.  You can modify them as you wish, but you should pay attention to where they are used in scripts to avoid bugs.

### Hosting the Installation Tarballs

**Update:** This feature is depricated.  The Stage 3 fetch and portage snapshot download is now an automated process you no longer have to worry about.  If you have already downloaded the tarballs using GentooDAD, this script will recognize their existance, and you will not have to download them twice.  (mirror web administrator friendly!)

#### Configuring Portage Mirrors

This is done by region.  You can change ``MIRROR_REGION`` in ``gentoo-config.sh`` to whatever you'd like.  The top 3 fastest mirrors in that region will be selected for you.

The default is ``North America``.

#### Hosting the files locally:

**Update:** This feature is depricated due to its delicate and advanced nature, it has been phased out of the main installation in favor of a more smart, automatic method with a proper download cache.

### CPU Configuration

This functionality is **in staging**.  Currently, ``sys-firmware/intel-microcode`` is installed for Intel CPUs.  Configuration values do not currently exist for the CPU.  This will change.

**AMD Users**

- ``gentoo-kernelcompile.sh`` Install ``sys-firmware/amd-microcode`` instead of ``sys-firmware/intel-microcode`` .

> **Note:** My apologies for the beta instructions here.  This functionality will become a configuration option soon.

### GPU Configuration

This functionality is **in staging**  Currently, ``nvidia`` proprietary drivers are installed for X. 

**Update:** GPU ``VIDEO_CARDS`` is configured automatically.  AMD users must still make some changes.  This will change.

**AMD GPU Users**

- ``gentoo-kernelcompile.sh`` Install the X11 AMD drivers instead of the NVIDIA X11 Drivers.
- ``gentoo-kernelcompile.sh`` Remove nvidia-xconfig invocation line.
- ``gentoo-injectconfig.sh`` Here-docment for ``package.use`` and ``package.license`` ``nvidia`` should be changed so that AMD drivers will install without issues.

> **Note:** My apologies for the beta instructions here.  This functionality will become a configuration option soon.

### Sound cards

THis functionality is **in beta** and works for some older cards.  If you have a problem with it, please file an issue ticket to have your sound card added to my database.

Your sound card is detected automatically via lspci and lsusb in the chroot and added to ``ALSA_CARDS`` automatically.

> **Note** THe system is currently configured to use ``alsa`` and ``pulseaudio``, to make any further changes to the system requires some significant changes.  This is a planned feature.

### Input devices

Currently, you must set ``OS_INPUT`` in ``gentoo-config.sh`` to the input libraries you wish to use.

The default values are ``libinput joystick mouse``

