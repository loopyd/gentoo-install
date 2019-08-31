#!/bin/bash

#- AUTO MAKE CONFIGULATOR! -#
#
echo 'Emerging cpuinfo2cpuflags and mirrorselect for make.conf autoconfiguration...'
emerge app-portage/cpuid2cpuflags mirrorselect

echo 'Copying portage make.conf template'
cat <<'EOF' > /etc/portage/make.conf
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

USE="X amd64 posix nptl smp avahi curl ipv6 acpi hddtemp libnotify lm_sensors pam readline syslog unicode usb openssl alsa pulseaudio kde pm-utils dbus policykit udisks lvm ffmpeg -gnome -static -systemd -bindist"

ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"
LC_MESSAGES=C

VIDEO_CARDS="nvidia intel"

# My system has a classic PS/2 mouse port for old keyboards, you can remove 'mouse' if want.
INPUT_DEVICES="libinput joystick mouse"

# Creative SoundBlaster Z / ReCon 3D (Gets ZxR somewhat working w/ new patch loading built into kernel >= 4.8)
# Thanks to the dude last year who ripped firmware from some HP Noteboke drivers.  HP sucks, you rock.
ALSA_CARDS="ca0132"

GRUB_PLATFORM="efi-64"
EOF

#- THE NEXT MORNING -#
# Painting the garage door!
#
echo "Autogenerating make.conf..."
echo 'Setting MAKEOPTS...'
perl -pi -e 's|(MAKEOPTS\=\")(.*)(")|${1}-j'$(perl -e'use POSIX; print ceil('$(nproc --all)'*0.5);')' -l'$(perl -e'use POSIX; print floor('$(nproc --all)'*0.9);')'${3}|g;' /etc/portage/make.conf
echo 'Setting COMMON_FLAGS...'
perl -pi -e 's|(COMMON\_FLAGS\=\")(.*)(")|${1}-march='$(gcc -march=native -Q --help=target | grep -- '-march=' | cut -f3)' -O2 -pipe${3}|g;' /etc/portage/make.conf
echo 'Setting CPU_FLAGS_X86...'
cmd='s|(CPU\_FLAGS\_X86\=\")(.*)(")|${1}'$(cpuid2cpuflags | cut -d' ' -f 2-)'${3}|g;'; perl -pi -e "$cmd" /etc/portage/make.conf
echo 'Setting GENTOO_MIRRORS...'
cmd='s|(GENTOO\_MIRRORS\=\")(.*)(")|${1}'$(mirrorselect -b50 -s3 -R 'North America' -q -o 2>/dev/null | perl -p -e 's|(GENTOO\_MIRRORS\=\")(.*)(")|${2}|g' | awk '{printf $0}')'${3}|g'; perl -pi -e "$cmd" /etc/portage/make.conf
