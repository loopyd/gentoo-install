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
``CHROOT_MOUNT`` | Where on the host the chroot will be mounted. | ``/mnt/gentoo`` | No
``HOME_LABEL`` | LVM label for the ``/home`` partition. | ``linux_home'`` | No
``ROOT_LABEL`` | LVM label for the ``/`` (root) partition. | ``linux_root`` | No
``SWAP_LABEL`` | LVM label for the ``swap`` partition. | ``linux_swap`` | No
``VARLOG_LABEL`` | LVM label for the ``/var/log`` partition. | ``var_log`` | No
``HOME_MOUNT`` | LVM device mountpoint for the ``home`` partition.  | ``/dev/mapper/gentoo-$HOME_LABEL`` | Yes
``ROOT_MOUNT`` | LVM device mountpoint for the ``/`` (root) partition. | ``/dev/mapper/gentoo-$ROOT_LABEL`` | Yes
``SWAP_MOUNT`` | LVM device mountpoint for the ``swap`` partition. | ``/dev/mapper/gentoo-$SWAP_LABEL`` | Yes
``VARLOG_MOUNT`` | LVM device mountpoint fo the ``/var/log`` partition. | ``/dev/mapper/gentoo-$VARLOG_LABEL`` | Yes
``BOOT_DEVICE`` | Device path for the ``/boot/efi`` partition. | ``/dev/nvme0n1p1'`` | No
``LVM_DEVICE`` | Device path for the LVM physical volume. | ``/dev/nvme0n1p2`` | No
``OS_DEVICE`` | Base device path for Gentoo installation | ``/dev/nvme0n1`` | No

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
2.  Replace according emerge line in ``gentoo-chroot-innerscript.sh`` to install the sources for the kernel you want to compile.  The default is ``ck-sources`` for **Linux-CK** for optimized desktop systems.

> **NOTE**: This script does no sanity checking whatsover, please make sure that your kernel compiles without
> help first !

### Dracut Initramfs

You can modify ``gentoo-config.sh`` underneath the initramfs section accordingly to load the kernel modules you need.

| Option | Use | Default | Autovar[2]
| --- | --- | --- | --- |
``DRACUT_KVER`` | Kernel version | ``5.1.7-ck`` | No
``DRACUT_MODULES`` | Dracut modules which should load in addition to your host's configuration. | ``lvm dm`` | No
``DRACUT_KERNEL_MODULES`` | Modules from your kernel which should load accordingly. | efivarfs igb bluetooth nvme-core nvme nvidia thunderbolt-net iptable_nat bpfilter team team_mode_broadcast team_mode_loadbalance team_mode_roundrobin vfio vfio_iommu_type1 vfio-pci | No

[2] Autovars are set automatically by **variable expansion**.  You can modify them as you wish, but you should pay attention to where they are used in scripts to avoid bugs.

### Account Credentials

You can change some details of the default user account that is created during the installation, as well as those for the root user.

| Option | Use | Default | Autovar[3]
| --- | --- | --- | --- |
USERNAME | Default user account name | ``heavypaws`` | Yes
PASSWORD | Default user account password | ``12345`` | Yes
ROOT_PASSWORD | Default root password | "123456" | Yes

[2] Autovars are set automatically by **variable expansion**.  You can modify them as you wish, but you should pay attention to where they are used in scripts to avoid bugs.

