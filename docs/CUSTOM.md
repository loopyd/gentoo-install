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
2.  Replace according emerge line in ``gentoo-chroot-innerscript.sh`` to install the sources for the kernel you want to compile.  The default is ``ck-sources`` for **Linux-CK** for optimized desktop systems.

> **NOTE**: This script does no sanity checking whatsover, please make sure that your kernel compiles without
> help first !

### Dracut Initramfs

You can modify ``gentoo-config.sh`` underneath the initramfs section accordingly to load the kernel modules you need.

| Option | Use | Default | Autovar[2]
| --- | --- | --- | --- |
**DRACUT_KVER** | Kernel version | ``5.1.7-ck`` | No
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

| Option | Use | Default | Autovar[4]
| --- | --- | --- | --- |
**MIRROR_SERVER_ADDRESS** | ``links`` will use this address to call up a tarballl mirror page.  I have this set to a LAN IP to host locally. | ``192.168.1.103`` | No
**ETH0_DEVICE** | First Ethernet adapter device name | ``enp10s0`` | No
**ETH0_ADDRESS** | First Ethernet adapter static IP | ``192.168.1.104`` | No
**ETH0_NETMASK** | First Ethernet adapter netmask | ``255.255.254.0`` | No
**ETH1_DEVICE** | Second Ethernet adapter device name | ``enp0s31f6`` | No
**ETH1_ADDRESS** | Second Ethernet adapter static IP | ``192.168.1.105`` | No
**ETH1_NETMASK** | Second Ethernet adapter netmask | ``255.255.254.0`` | No
**GATEWAY_ADDRESS** | Gateway IP address | ``192.168.1.1`` | No
**DNS1_ADDRESS** | Primary DNS server | ``8.8.8.8`` | No
**DNS2_ADDRESS** | Secondary DNS server | ``8.8.4.4`` | No

[4] Autovars are set automatically by **variable expansion**.  You can modify them as you wish, but you should pay attention to where they are used in scripts to avoid bugs.

### Account Credentials

You can change some details of the default user account that is created during the installation, as well as those for the root user.

| Option | Use | Default | Autovar[3]
| --- | --- | --- | --- |
**USERNAME** | Default user account name | ``heavypaws`` | Yes
**PASSWORD** | Default user account password | ``12345`` | Yes
**ROOT_PASSWORD** | Default root password | ``123456`` | Yes

[2] Autovars are set automatically by **variable expansion**.  You can modify them as you wish, but you should pay attention to where they are used in scripts to avoid bugs.

### Hosting the Installation Tarballs

For hosting the tarballs for the installatiion, you have **a few options**:

#### Using gentoo's mirrors with ``links``:

Set ``MIRROR_SERVER_ADDRESS`` in ``gentoo-config.sh`` to a mirror of your choice from [this page](https://www.gentoo.org/downloads/mirrors/)

No further configuration is required with this method.

#### Hosting the files locally:

You can use a LAN-side HTTP server running on a laptop to host your files.  I used a basic Bitnami WAMP stack.  I left this section of the guide open.
As long as your server is capable of hosting files and accessable on your LAN, it will work for this step of the installation.

Here is a basic 'Download Page' template you can use for ``index.html``

```
<!DOCTYPE html>
<HEAD>
	<TITLE>Gentoo Install Files</TITLE>
</HEAD>
<BODY>
	<H1>Gentoo Installation Files</H1>
	<LIST>
	<LI><A HREF="files/gentoo-install.sh">Installer Script</A></LI>
	<LI><A HREF="files/stage3-amd64-hardened-20190811T214502Z.tar.xz">Stage 3 Tarball</A></LI>
	<LI><A HREF="files/portage-latest.tar.xz">Portage Latest Snapshot</A></LI>
	</LIST>
</BODY>
```

Modify it as need-be.  It links inside of the ``files/`` directory in ``htdocs`` .  Put the tarballs in that folder, change the filenames, and host your LAN HTTP server on a laptop or another computer.  You can then browse this directory during the install process and quickly download the tarballs over LAN.  (Useful for debugging!)

Set ``MIRROR_SERVER_ADDRESS`` in ``gentoo-config.sh`` to the LAN IP of your HTTP server.

### CPU Configuration

This functionality is **in beta**.  Currently, ``sys-firmware/intel-microcode`` is installed for Intel CPUs.  Configuration values do not currently exist for the CPU.  This will change.

**AMD Users**

- ``gentoo-chroot-innerscript.sh`` Install ``sys-firmware/amd-microcode`` instead of ``sys-firmware/intel-microcode`` .
- ``gentoo-injectconfig.sh`` - ``VIDEO_CARDS`` in ``make.conf`` automakeconf generator.  Remove ``intel`` .

``CPU_FLAGS_X86`` automatic setting has been implimented.  You don't have to worry about configuring this value.  Its done for you.

> **Note:** My apologies for the beta instructions here.  This functionality will become a configuration option soon.

### GPU Configuration

This functionality is **in beta**  Currently, ``nvidia`` proprietary drivers are installed for X.  Modifications will need to be made:

**AMD GPU Users**

- ``gentoo-chroot-innerscript.sh`` Install the X11 AMD drivers instead of the NVIDIA X11 Drivers.
- ``gentoo-chroot-innerscript.sh`` Remove nvidia-xconfig invocation line.
- ``gentoo-injectconfig.sh`` Here-docment for ``package.use`` and ``package.license`` ``nvidia`` should be changed so that AMD drivers will install without issues.
- ``gentoo-injectconfig.sh`` - ``VIDEO_CARDS`` in ``make.conf`` automakeconf generator.  Add ``amd`` or ``radeon`` depending on what you need.

> **Note:** My apologies for the beta instructions here.  This functionality will become a configuration option soon.