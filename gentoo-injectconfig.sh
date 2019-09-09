#!/bin/bash

#- UPDATE LIVECD -#
echo 'Updating LiveCD portage installation...'
emerge --sync
eselect profile set 5

#- This here document allows unattended use of portage on the LiveCD, don't change it. -#
echo 'Inserting base use flag setup for LiveCD...'
cat <<'EOFDOC' > /etc/portage/package.use/base
dev-qt/qtwebkit gstreamer icu
net-wireless/wpa_supplicant -qt4
dev-vcs/subversion -kde
net-wireless/wpa_supplicant -qt4
dev-util/cmake -qt5
dev-qt/qtnetwork -networkmanager
dev-qt/qtgui -harfbuzz
media-video/vlc -qt4
kde-plasma/plasma-desktop legacy-systray
x11-libs/libdrm libkms
media-libs/mesa -opencl llvm vdpau xa
sys-fs/lvm2 static-libs
net-vpn/openvpn plugins
dev-libs/openssl static-libs
net-misc/networkmanager gnutls dhcpcd bluetooth wifi consolekit -nss -dhclient
net-misc/curl curl_ssl_openssl
media-video/ffmpeg v4l zlib encode gpl -xcb
dev-qt/qtgui xcb
app-text/gnome-doc-utils python_targets_python2_7
app-accessibility/brltty python_targets_python2_7
app-office/texmaker qt5 -qt4
>=dev-qt/qtdeclarative-4.8.7:4 webkit
>=dev-lang/python-2.7.10:2.7 sqlite
>=dev-libs/libxml2-2.9.2-r1 icu
>=net-wireless/lorcon-0.0_p20150109 python
>=dev-qt/qtwebkit-5.4.2 printsupport
>=sys-devel/llvm-3.7.0 clang
>=x11-libs/libdrm-2.4.64 libkms
>=media-libs/mesa-11.0.0_rc2 xa
>=media-libs/phonon-vlc-0.8.2 qt5
>=x11-libs/libxkbcommon-0.5.0 X
>=kde-frameworks/kwindowsystem-5.13.0 X
>=media-libs/phonon-4.8.3-r1 qt5 qt4
>=net-wireless/wpa_supplicant-2.4-r4 dbus
>=dev-qt/qtcore-5.4.2 icu
>=sys-libs/zlib-1.2.8-r1 minizip
>=app-crypt/pinentry-0.9.5 gnome-keyring
>=media-libs/harfbuzz-0.9.41 icu
sys-libs/ncurses -gpm
>=dev-libs/libpcre-8.37-r2 pcre16
sys-libs/ncurses -gpm
net-fs/samba winbind
app-office/libreoffice -eds -python_single_target_python2_7 python_single_target_python3_4
app-office/scribus -pdf
>=sys-libs/tdb-1.3.7 python
>=sys-libs/tevent-0.9.25 python
>=sys-libs/ntdb-1.0-r1 python
>=app-crypt/heimdal-1.5.3-r2 -ssl
>=media-gfx/exiv2-0.24-r1 xmp
>=dev-ruby/racc-1.4.12 ruby_targets_ruby22
>=dev-ruby/rake-10.4.2 ruby_targets_ruby22
>=dev-ruby/power_assert-0.2.4 ruby_targets_ruby22
>=dev-ruby/test-unit-3.1.3 ruby_targets_ruby22
>=dev-ruby/minitest-5.8.0 ruby_targets_ruby22
>=dev-ruby/json-1.8.3 ruby_targets_ruby22
>=dev-ruby/rdoc-4.1.2-r1 ruby_targets_ruby22
>=sys-devel/llvm-3.5.0 clang
>=virtual/rubygems-11 ruby_targets_ruby22
>=dev-ruby/rubygems-2.4.8 ruby_targets_ruby22
>=media-video/ffmpeg-2.8.1 opus vpx
>=media-libs/opencv-3.0.0 contrib
>=app-text/texlive-core-2015 cjk xetex
>=dev-libs/libgdata-0.17.3 gnome
>=x11-libs/libdrm-2.4.65 video_cards_amdgpu
>=media-libs/mesa-11.0.6 wayland
>=dev-ruby/rake-10.4.2 ruby_targets_ruby23
>=dev-ruby/power_assert-0.2.6 ruby_targets_ruby23
>=virtual/rubygems-11 ruby_targets_ruby23
>=dev-ruby/minitest-5.8.3 ruby_targets_ruby23
>=dev-ruby/rdoc-4.2.1 ruby_targets_ruby23
>=dev-ruby/racc-1.4.14 ruby_targets_ruby23
>=dev-ruby/test-unit-3.1.5-r1 ruby_targets_ruby23
>=dev-ruby/rubygems-2.5.1 ruby_targets_ruby23
>=dev-ruby/did_you_mean-1.0.0 ruby_targets_ruby23
>=dev-ruby/net-telnet-0.1.1 ruby_targets_ruby23
>=dev-ruby/json-1.8.3 ruby_targets_ruby23
dev-qt/qtmultimedia gstreamer
lxqt-base/lxqt-meta sddm minimal
EOFDOC

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
cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.license/kde
media-libs/faac MPEG-4
net-misc/dropbox CC-BY-ND-3.0 dropbox
EOF

cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.accept_keywords/kde
dev-libs/openssl ~amd64
x11-plugins/pidgin-indicator ~amd64
EOF
 
cat <<'EOF' > $CHROOT_MOUNT/etc/portage/package.use/kde
dev-lang/python sqlite
x11-libs/libdrm libkms
net-libs/telepathy-qt farstream
media-plugins/gst-plugins-meta v4l theora
media-libs/gst-plugins-base v4l theora
kde-plasma/plasma-meta browser-integration crypt display-manager grub gtk pam wallpapers sdk sddm consolekit pm-utils legacy-systray
kde-plasma/kde-cli-tools kdesu
sys-fs/udisks introspection lvm vdo
sys-libs/libblockdev vdo lvm
sys-auth/polkit consolekit introspection
sys-auth/consolekit policykit acl pm-utils evdev
dev-libs/libpcre2 pcre16
app-text/xmlto text
x11-libs/libxcb xkb
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
