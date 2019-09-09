#!/bin/bash

# Kernel config
KERNEL_RELEASE_VER='gentoo'
KERNEL_FULL_VER='5.2.8'
KERNEL_MINOR_VER=$(echo -n $KERNEL_FULL_VER | cut -d'.' -f1-2)

# Dracut config
DRACUT_MODULES='lvm dm'
DRACUT_KERNEL_MODULES='efivarfs igb nvme-core nvme nvidia iptable_nat bpfilter team team_mode_broadcast team_mode_loadbalance team_mode_roundrobin snd-mixer-oss snd-pcm-oss snd-seq-oss snd-seq-midi-event snd-seq snd-hrtimer snd-hwdep snd-pcm snd-rawmidi snd-seq-device snd-timer snd snd-hda-ext-core snd-hda-core snd-usb-audio snd-usbmidi-lib snd-hda-codec-generic snd-hda-intel snd-usb-audio snd-hda-codec-hdmi snd-hda-codec-ca0132'

# Inject portage configurations
echo 'Injecting package.accept_keywords for sys-kernel...'
cat <<EOF > /etc/portage/package.accept_keywords/sys-kernel
=sys-kernel/$KERNEL_RELEASE_VER-sources-$KERNEL_FULL_VER ~amd64
=sys-kernel/linux-headers-$KERNEL_MINOR_VER ~amd64
EOF
echo 'Injecting package.use for sys-boot...'
cat <<EOF > /etc/portage/package.use/sys-boot
sys-boot/grub mount device-mapper fonts theme truetype
EOF
echo 'Injecting package.license for sys-firmware...'
cat <<EOF >/etc/portage/package.accept_license/sys-firmware
sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE
sys-firmware/intel-microcode intel-ucode
EOF
echo 'Injecting package.license for nvidia-drivers...'
cat <<EOF > /etc/portage/package.license/nvidia-drivers
x11-drivers/nvidia-drivers NVIDIA-r2
EOF
echo 'Injecting package.use for nvidia-drivers..'
cat <<EOF > /etc/portage/package.use/nvidia-drivers
media-libs/vulkan-layers layers
media-libs/vulkan-loader layers
media-libs/mesa -vulkan
dev-db/sqlite secure-delete
EOF

echo 'Emerging kernel sources...'
emerge =sys-kernel/$KERNEL_RELEASE_VER-sources-$KERNEL_FULL_VER
echo 'Emerging kernel headers...'
emerge =sys-kernel/linux-headers-$KERNEL_MINOR_VER

# Compile kernel
echo 'Compiling kernel...'
cd /usr/src/linux
make clean && make mrproper
cp ~/kernel-config.txt /usr/src/linux/.config
make syncconfig
make -j8
make modules_install
make install
cd ~

echo 'Configuring bfq scheduler udev rules...'
cat <<EOF > /etc/udev/rules.d/60-scheduler.rules
ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="bfq"
EOF

echo 'Emerging X drivers...'
emerge x11-drivers/nvidia-drivers
emerge emerge x11-base/xorg-drivers
eselect opengl set nvidia
eselect opencl set nvidia

echo 'Emerging linux firmware...'
emerge linux-firmware

echo 'Emerging intel-microcode...'
emerge intel-microcode

echo 'Emerging alsa-plugins...'
emerge alsa-plugins alsa-lib

# TODO: Move this
echo 'Installing X configuration...'
nvidia-xconfig

# Initramfs installation
echo 'Enabling efivarfs...'
umount -v efivarfs && mount -v efivarfs

echo 'Emerging dracut...'
emerge dracut

echo 'Compiling initramfs...'
dracut --kver $KERNEL_FULL_VER-$KERNEL_RELEASE_VER -H --add "$DRACUT_MODULES" --add-drivers "$DRACUT_KERNEL_MODULES" -i /lib/firmware /lib/firmware--hostonly-cmdline --fstab --gzip --lvmconf --early-microcode --force /boot/initramfs-$KERNEL_FULL_VER-$KERNEL_RELEASE_VER.img

# OpenRC refresh and udev installation
echo 'Emerging virtual/udev as udev provider...'
emerge virtual/udev

# Bootloader installation
echo 'Emerging grub and filesystem dependencies...'
emerge sys-boot/grub:2 lvm2 os-prober sys-apps/pciutils sys-apps/usbutils sys-apps/hwinfo sys-fs/dosfstools xfsprogs e2fsprogs

echo 'Configuring grub...'
cat <<EOF > /etc/default/grub
GRUB_DISTRIBUTOR="Gentoo"
GRUB_CMDLINE_LINUX="rd.auto=1 scsi_mod.use_blk_mq=1"
EOF

echo 'Installing grub...'
grub-install $OS_DEVICE --efi-directory=/boot/efi --target=x86_64-efi --no-floppy
grub-mkconfig -o /boot/grub/grub.cfg
