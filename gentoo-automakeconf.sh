#!/bin/bash

#- AUTO MAKE CONFIGULATOR! -#
#
echo 'Emerging cpuinfo2cpuflags and mirrorselect for make.conf autoconfiguration...'
emerge --sync

#- This here document allows unattended use of portage on the LiveCD, don't change it.
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

emerge app-portage/cpuid2cpuflags mirrorselect

echo 'Copying portage make.conf template'
cat <<'EOF' > $CHROOT_MOUNT/etc/portage/make.conf
ARCH=""
COMMON_FLAGS="-O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
CHOST="x86_64-pc-linux-gnu"
MAKEOPTS=""
CPU_FLAGS_X86=""

DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"
PORTAGE_TMPDIR="/var/tmp/portage"
EMERGE_DEFAULT_OPTS="--jobs 3 --with-bdeps-auto=y --deep --autounmask=y --autounmask-write=y --quiet=y --keep-going=y" 
GENTOO_MIRRORS=""

USE="${ARCH} X posix nptl smp avahi curl ipv6 acpi hddtemp libnotify lm_sensors pam readline syslog unicode usb openssl alsa pulseaudio kde pm-utils dbus policykit udisks lvm ffmpeg -gnome -static -systemd -bindist"

ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"
LC_MESSAGES=C

VIDEO_CARDS=""
INPUT_DEVICES=""
ALSA_CARDS=""

GRUB_PLATFORM="efi-64"
EOF

#- THE NEXT MORNING -#
# Painting the garage door!
#
echo "Autogenerating make.conf..."
echo 'Setting MAKEOPTS...'
perl -pi -e 's|(MAKEOPTS\=\")(.*)(")|${1}-j'$(perl -e'use POSIX; print ceil('$(nproc --all)'*0.5);')' -l'$(perl -e'use POSIX; print floor('$(nproc --all)'*0.9);')'${3}|g;' $CHROOT_MOUNT/etc/portage/make.conf
echo 'Setting COMMON_FLAGS...'
perl -pi -e 's|(COMMON\_FLAGS\=\")(.*)(")|${1}-march='$(gcc -march=native -Q --help=target | grep -- '-march=' | cut -f3)' -O2 -pipe${3}|g;' $CHROOT_MOUNT/etc/portage/make.conf
echo 'Setting CPU_FLAGS_X86...'
cmd='s|(CPU\_FLAGS\_X86\=\")(.*)(")|${1}'$(cpuid2cpuflags | cut -d' ' -f 2-)'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
echo 'Setting GENTOO_MIRRORS...'
cmd='s|(GENTOO\_MIRRORS\=\")(.*)(")|${1}'$(mirrorselect -b50 -s3 -R "$MIRROR_REGION" -q -o 2>/dev/null | perl -p -e 's|(GENTOO\_MIRRORS\=\")(.*)(")|${2}|g' | awk '{printf $0}')'${3}|g'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
echo 'Setting ARCH...'
cmd='s|(ARCH\=\")(.*)(")|${1}'$(/root/gentoo-hardwarehelper.sh "cpu_arch")'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
echo 'Setting VIDEO_CARDS...'
cmd='s|(VIDEO\_CARDS\=\")(.*)(")|${1}'$(/root/gentoo-hardwarehelper.sh "gpu_vendors")'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
echo 'Setting ALSA_CARDS...'
cmd='s|(ALSA\_CARDS\=\")(.*)(")|${1}'$(/root/gentoo-hardwarehelper.sh "sound_vendors")'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
# TODO: gentoo-hardwarehelper.sh - input_provers
echo 'Setting INPUT_DEVICES...'
cmd='s|(INPUT\_DEVICES\=\")(.*)(")|${1}'$(echo -n "$OS_INPUT")'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
