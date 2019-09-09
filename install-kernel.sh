#!/bin/bash

# Kernel config
KERNEL_RELEASE_VER='gentoo'
KERNEL_FULL_VER='5.2.8'
KERNEL_MINOR_VER=$(echo -n $KERNEL_FULL_VER | cut -d'.' -f1-2)

# Dracut config
DRACUT_MODULES='lvm dm'
DRACUT_KERNEL_MODULES='efivarfs igb nvme-core nvme nvidia iptable_nat bpfilter team team_mode_broadcast team_mode_loadbalance team_mode_roundrobin snd-mixer-oss snd-pcm-oss snd-seq-oss snd-seq-midi-event snd-seq snd-hrtimer snd-hwdep snd-pcm snd-rawmidi snd-seq-device snd-timer snd snd-hda-ext-core snd-hda-core snd-usb-audio snd-usbmidi-lib snd-hda-codec-generic snd-hda-intel snd-usb-audio snd-hda-codec-hdmi snd-hda-codec-ca0132'

# Install kernel sources
echo 'Injecting package.accept_keywords for sys-kernel...'
cat <<EOF > /etc/portage/package.accept_keywords/sys-kernel
=sys-kernel/$KERNEL_RELEASE_VER-sources-$KERNEL_FULL_VER ~amd64
=sys-kernel/linux-headers-$KERNEL_MINOR_VER ~amd64
EOF
echo 'Injecting package.use for sys-boot...'
cat <<EOF > /etc/portage/package.use/sys-boot
sys-boot/grub mount device-mapper fonts theme truetype
EOF
echo 'Emerging kernel sources...'
# emerge =sys-kernel/$KERNEL_RELEASE_VER-sources-$KERNEL_FULL_VER
echo 'Emerging kernel headers...'
# emerge =sys-kernel/linux-headers-$KERNEL_MINOR_VER

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

# Compile video, audio, chipset (modules, firmware, microcode)
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
echo 'Emerging nvidia drivers...'
emerge x11-drivers/nvidia-drivers 
echo 'Emerging linux firmware...'
emerge linux-firmware
echo 'Emerging intel-microcode...'
emerge intel-microcode

echo 'Emerging alsa-plugins...'
emerge alsa-plugins alsa-lib

# Compile and install dracut initramfs
dracut --kver $KERNEL_FULL_VER-$KERNEL_RELEASE_VER -H --add "$DRACUT_MODULES" --add-drivers "$DRACUT_KERNEL_MODULES" -i /lib/firmware /lib/firmware--hostonly-cmdline --fstab --gzip --lvmconf --early-microcode --force /boot/initramfs-$KERNEL_FULL_VER-$KERNEL_RELEASE_VER.img






