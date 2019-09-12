#!/bin/bash

echo 'Enabling efivarfs...'
umount -v efivarfs && mount -v efivarfs

echo 'Emerging dependencies...'
emerge --newuse --deep =sys-kernel/$KERNEL_RELEASE_VER-sources-$KERNEL_FULL_VER =sys-kernel/linux-headers-$KERNEL_MINOR_VER dracut virtual/udev sys-boot/grub:2 lvm2 os-prober sys-apps/pciutils sys-apps/usbutils sys-apps/hwinfo sys-fs/dosfstools xfsprogs e2fsprogs

# Compile kernel
echo 'Compiling kernel...'
cd /usr/src/linux
make clean
cp ~/kernel-config.txt /usr/src/linux/.config
make syncconfig
make -j6
make modules_install
make install
cd ~

echo 'Emerging GPU drivers...'
emerge --newuse --deep x11-base/xorg-drivers
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

echo 'Emerging sound drivers...'
emerge --newuse --deep alsa-plugins alsa-lib

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
rc-update lvm add boot