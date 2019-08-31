#!/bin/bash

#- AUTO MAKE CONFIGULATOR! -#
#
echo 'Emerging cpuinfo2cpuflags and mirrorselect for make.conf autoconfiguration...'
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
perl -pi -e 's|(ARCH\=\")(.*)(")|${1}'$(/root/gentoo-hardwarehelper.sh "cpu_arch")'${3}|g;' $CHROOT_MOUNT/etc/portage/make.conf
echo 'Setting VIDEO_CARDS...'
perl -pi -e 's|(VIDEO\_CARDS\=\")(.*)(")|${1}'$(/root/gentoo-hardwarehelper.sh "gpu_vendors")'${3}|g;' $CHROOT_MOUNT/etc/portage/make.conf
echo 'Setting ALSA_CARDS...'
perl -pi -e 's|(ALSA\_CARDS\=\")(.*)(")|${1}'$(/root/gentoo-hardwarehelper.sh "sound_vendors")'${3}|g;' $CHROOT_MOUNT/etc/portage/make.conf
# TODO: gentoo-hardwarehelper.sh - input_provers
echo 'Setting INPUT_DEVICES...'
perl -pi -e 's|(INPUT\_DEVICES\=\")(.*)(")|${1}'$(echo -n "$OS_INPUT")'${3}|g;' $CHROOT_MOUNT/etc/portage/make.conf
