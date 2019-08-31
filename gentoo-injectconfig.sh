#!/bin/bash

echo 'Patching root password for chroot...'
sed -i -e 's/^root:\*/root:/' $CHROOT_MOUNT/etc/shadow

#- CONFIGULATOR! -#
# I'll config you later~
echo 'Injecting locale configuration for en_US...'
cat <<EOF >> $CHROOT_MOUNT/etc/locale.gen
$LOCALES_TOGEN
EOF

cat <<EOF >> $CHROOT_MOUNT/etc/env.d/02locale 
LANG="$DEFAULT_LOCALE"
LC_COLLATE="C"
EOF

echo 'Injecting timezone configuration...'
cat <<EOF > $CHROOT_MOUNT/etc/timezone
$TIMEZONE
EOF
 
echo 'Injecting network configuration...'
cat <<EOF > $CHROOT_MOUNT/etc/hosts
127.0.0.1 $USERNAME-pc.localdomain $USERNAME-pc localhost
::1 $USERNAME-pc.localdomain $USERNAME-pc localhost
EOF

cat <<EOF > $CHROOT_MOUNT/etc/hostname
$USERNAME-pc
EOF

cat <<EOF > $CHROOT_MOUNT/etc/resolv.conf
nameserver $DNS1_ADDRESS
nameserver $DNS2_ADDRESS
EOF

# in-place here document with variable expansion
cat <<EOF > $CHROOT_MOUNT/etc/conf.d/net
config_$ETH0_DEVICE="$ETH0_ADDRESS netmask $ETH0_NETMASK"
routes_$ETH0_DEVICE="default via $GATEWAY_ADDRESS"
dns_servers_$ETH0_DEVICE="$DNS1_ADDRESS $DNS2_ADDRESS"
config_$ETH1_DEVICE="$ETH1_ADDRESS netmask $ETH1_NETMASK"
routes_$ETH1_DEVICE="default via $GATEWAY_ADDRESS"
dns_servers_$ETH1_DEVICE="$DNS1_ADDRESS $DNS2_ADDRESS"
EOF

cd $CHROOT_MOUNT/etc/init.d
ln -s net.lo net.$ETH0_DEVICE
ln -s net.lo net.$ETH1_DEVICE
cd ~

#- PORTAGE JUNK IN THE BIG PAW'S TRUNK -#
# Portage sounds like an orafice you can-....  nevermind.
echo 'Cleaning out portage directories...'
rm -f $CHROOT_MOUNT/etc/portage/package.mask >/dev/null 2>&1
rm -fdr $CHROOT_MOUNT/etc/portage/package.mask >/dev/null 2>&1
rm -f $CHROOT_MOUNT/etc/portage/package.use >/dev/null 2>&1
rm -fdr $CHROOT_MOUNT/etc/portage/package.use >/dev/null 2>&1
rm -f $CHROOT_MOUNT/etc/portage/package.license >/dev/null 2>&1
rm -fdr $CHROOT_MOUNT/etc/portage/package.license >/dev/null 2>&1
rm -f $CHROOT_MOUNT/etc/portage/package.accept_keywords >/dev/null 2>&1
rm -fdr $CHROOT_MOUNT/etc/portage/package.accept_keywords >/dev/null 2>&1
mkdir $CHROOT_MOUNT/etc/portage/package.mask >/dev/null 2>&1
mkdir $CHROOT_MOUNT/etc/portage/package.use >/dev/null 2>&1
mkdir $CHROOT_MOUNT/etc/portage/package.license >/dev/null 2>&1
mkdir $CHROOT_MOUNT/etc/portage/package.accept_keywords >/dev/null 2>&1
mkdir $CHROOT_MOUNT/etc/portage/repos.conf >/dev/null 2>&1
mkdir --parents $CHROOT_MOUNT/var/db/repos/gentoo >/dev/null 2>&1

echo 'Copying portage repo configuration...'
cp $CHROOT_MOUNT/usr/share/portage/config/repos.conf $CHROOT_MOUNT/etc/portage/repos.conf/gentoo.conf

#-- fixes for portage --#
echo 'Copying portage package configuration...'
cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.use/zu-layman
app-portage/layman sync-plugin-portage
EOF

#--- fixes for KDE build. ---#
echo 'Copying KDE package configuration...'
cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.license/zr-kde-apps
EOF

cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.accept_keywords/zq-pidgin-indicator
=x11-plugins/pidgin-indicator-1.0 ~amd64
EOF

cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.license/zs-kde
>=media-libs/faac-1.29.9.2 MPEG-4
=net-misc/dropbox-48.3.56 CC-BY-ND-3.0 dropbox
EOF

cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.accept_keywords/zr-kde
>=dev-libs/openssl-1.1.1c-r1 ~amd64
EOF
 
cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.use/zw-kde
>=dev-lang/python-2.7.15:2.7 sqlite
>=x11-libs/libdrm-2.4.97 libkms
>=net-libs/telepathy-qt-0.9.7-r1 farstream
>=media-plugins/gst-plugins-meta-1.14.3 v4l theora
>=media-libs/gst-plugins-base-1.14.4-r1 theora
>=dev-lang/python-3.6.5 sqlite
kde-plasma/plasma-meta browser-integration crypt display-manager grub gtk pam wallpapers sdk sddm consolekit pm-utils legacy-systray
kde-plasma/kde-cli-tools kdesu
sys-fs/eudev abi_x86_32
sys-fs/udisks introspection lvm vdo
sys-libs/libblockdev vdo lvm
sys-auth/polkit consolekit introspection
sys-auth/consolekit policykit acl pm-utils evdev
>=dev-libs/libpcre2-10.32 pcre16
>=app-text/xmlto-0.0.28-r1 text
>=x11-libs/libxcb-1.13.1 xkb
>=dev-qt/qtcore-5.12.3 icu
EOF

#-- fxies for nvidia --#
echo 'Copying nvidia package configuration...'
cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.license/nvidia-drivers
>=x11-drivers/nvidia-drivers-430.40 NVIDIA-r2
EOF

cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.use/zy-nvidia-drivers
>=x11-libs/gdk-pixbuf-2.38.1 X
>=x11-libs/pango-1.42.4-r1 X
>=x11-libs/libX11-1.6.8 abi_x86_32
>=x11-libs/libXext-1.3.4 abi_x86_32
>=x11-libs/libvdpau-1.2 abi_x86_32
>=sys-libs/zlib-1.2.11-r2 abi_x86_32
>=x11-libs/cairo-1.16.0-r3 X
>=x11-libs/libxcb-1.13.1 abi_x86_32
>=virtual/pkgconfig-1 abi_x86_32
>=dev-util/pkgconf-1.5.4 abi_x86_32
>=dev-libs/libpthread-stubs-0.4-r1 abi_x86_32
>=x11-libs/libXau-1.0.9 abi_x86_32
>=x11-libs/libXdmcp-1.1.3 abi_x86_32
>=x11-base/xcb-proto-1.13 abi_x86_32
EOF

#--- fixes for kernel and grub ---#
echo 'Copying kernel and grub package configuration...'
cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.license/kernel
app-arch/unrar unRAR
sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE
sys-firmware/intel-microcode intel-ucode
EOF

cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.accept_keywords/sys-kernel
=sys-kernel/ck-sources-5.1.7 ~amd64
=sys-kernel/linux-headers-5.1 ~amd64
EOF

cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.use/zx-grub-2
>=sys-boot/grub-2.02-r4 mount device-mapper fonts theme truetype
EOF


#- Fstab -#
# Put the knife down, dave!
#
echo 'Copying fstab...'

# variable-expanded here-document.  Notice the lack of single quotes around EOF.
cat <<EOF > $CHROOT_MOUNT/etc/fstab
$BOOT_DEVICE /boot/efi vfat noatime 0 2
$SWAP_MOUNT none swap sw 0 0
$ROOT_MOUNT / xfs rw,noatime,attr2,inode64,noquota 0 1
$HOME_MOUNT /home ext4 rw,noatime,noquota 0 1
$VARLOG_MOUNT /var/log ext4 rw,noatime 0 2
tmpfs /tmp tmpfs rw,nosuid,noatime,nodev,mode=1777 0 2
tmpfs /var/tmp tmpfs rw,nosuid,noatime,nodev,mode=1777,size=16G 0 0
tmpfs /var/tmp/portage tmpfs rw,nosuid,noatime,nodev,mode=755,size=16G,uid=portage,gid=portage,x-mount.mkdir=755 0 0
efivarfs /sys/firmware/efi/efivars efivarfs rw,nosuid,nodev,noexec,relatime 0 0
EOF

cp -f ./kernel-config.txt $CHROOT_MOUNT/root/kernel-config.txt
cp -f ./*.sh $CHROOT_MOUNT/root
chmod +x $CHROOT_MOUNT/root/*.sh

echo 'Injecting omplete'