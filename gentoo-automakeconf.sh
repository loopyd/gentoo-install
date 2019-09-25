#!/bin/bash

#- AUTO MAKE CONFIGULATOR! -#
#
echo "${TEXT_BOLD}${TEXT_WARNING}EMERGE:${TEXT_NORMAL}${TEXT_BOLD}  Emering cpuinfo2cpuflags...${TEXT_NORMAL}"
emerge app-portage/cpuinfo2cpuflags

echo "${TEXT_BOLD}${TEXT_WARNING}COPY:${TEXT_NORMAL}${TEXT_BOLD}  Copying base make.conf${TEXT_NORMAL}"
cat <<'EOF' > $CHROOT_MOUNT/etc/portage/make.conf
ARCH=""
COMMON_FLAGS="-O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
CHOST="x86_64-pc-linux-gnu"
LANG=C
LC_ALL=C
LC_CTYPE=C
LC_MESSAGES=C
ABI_X86=""
MAKEOPTS=""
CPU_FLAGS_X86=""

DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"
PORTAGE_TMPDIR="/var/tmp/portage"
EMERGE_DEFAULT_OPTS="--jobs 6 --with-bdeps-auto=y --deep --autounmask=y --autounmask-write=y --autounmask-backtrack=y --quiet=y --keep-going=y" 
GENTOO_MIRRORS=""

USE=""
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"

RUBY_TARGETS="ruby24 ruby26"

VIDEO_CARDS=""
INPUT_DEVICES=""
ALSA_CARDS=""

GRUB_PLATFORM="efi-64"
EOF

echo "${TEXT_BOLD}${TEXT_WARNING}RUNNING:${TEXT_NORMAL}${TEXT_BOLD}  Automakeconf running...${TEXT_NORMAL}"

#- THE NEXT MORNING -#
# Barf city, barf city, barf citaaay! [ distortion-guitar-stock-footage.wav ]
#
echo "Setting ${TEXT_BOLD}MAKEOPTS${TEXT_NORMAL}..."
perl -pi -e 's|(MAKEOPTS\=\")(.*)(")|${1}-j'$(perl -e'use POSIX; print ceil('$(nproc --all)'*0.5);')' -l'$(perl -e'use POSIX; print floor('$(nproc --all)'*0.9);')'${3}|g;' $CHROOT_MOUNT/etc/portage/make.conf
echo "Setting ${TEXT_BOLD}COMMON_FLAGS${TEXT_NORMAL}..."
perl -pi -e 's|(COMMON\_FLAGS\=\")(.*)(")|${1}-march='$(gcc -march=native -Q --help=target | grep -- '-march=' | cut -f3)' -O2 -pipe${3}|g;' $CHROOT_MOUNT/etc/portage/make.conf
echo "Setting ${TEXT_BOLD}CPU_FLAGS_X86${TEXT_NORMAL}..."
cmd='s|(CPU\_FLAGS\_X86\=\")(.*)(")|${1}'$(cpuid2cpuflags | cut -d' ' -f 2-)'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
echo "Setting ${TEXT_BOLD}GENTOO_MIRRORS${TEXT_NORMAL}..."
cmd='s|(GENTOO\_MIRRORS\=\")(.*)(")|${1}'$(mirrorselect -b50 -s3 -R "$MIRROR_REGION" -q -o 2>/dev/null | perl -p -e 's|(GENTOO\_MIRRORS\=\")(.*)(")|${2}|g' | awk '{printf $0}')'${3}|g'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
echo "Setting ${TEXT_BOLD}ARCH${TEXT_NORMAL}..."
cmd='s|(ARCH\=\")(.*)(")|${1}'$(/root/gentoo-hardwarehelper.sh "cpu_arch")'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
echo "Setting ${TEXT_BOLD}VIDEO_CARDS${TEXT_NORMAL}..."
cmd='s|(VIDEO\_CARDS\=\")(.*)(")|${1}'$(/root/gentoo-hardwarehelper.sh "gpu_vendors")'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
echo "Setting ${TEXT_BOLD}ALSA_CARDS${TEXT_NORMAL}..."
cmd='s|(ALSA\_CARDS\=\")(.*)(")|${1}'$(/root/gentoo-hardwarehelper.sh "sound_vendors")'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
# TODO: gentoo-hardwarehelper.sh - input_provers
echo "Setting ${TEXT_BOLD}INPUT_DEVICES${TEXT_NORMAL}..."
cmd='s|(INPUT\_DEVICES\=\")(.*)(")|${1}'$(echo -n "$OS_INPUT")'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
echo "Setting ${TEXT_BOLD}USE${TEXT_NORMAL}..."
cmd='s|(USE\=\")(.*)(")|${1}'$(echo -n "$OS_GLOBAL_USE")'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
CPU_VENDOR=$(/root/gentoo-hardwarehelper.sh "cpu_arch")
if [[ $CPU_VENDOR == *"86" ]] || [[ $CPU_VENDOR == "amd" ]]; then
	ABI_OPTS='32'
elif [[ $CPU_VENDOR == *"64"* ]]; then
	ABI_OPTS='32 64'
fi
cmd='s|(ABI_X86\=\")(.*)(")|${1}'$(echo -n "$ABI_OPTS")'${3}|g;'; perl -pi -e "$cmd" $CHROOT_MOUNT/etc/portage/make.conf
echo "${TEXT_BOLD}${TEXT_OK}COMPLETE:${TEXT_NORMAL}${TEXT_BOLD}  Automakeconf finished.${TEXT_NORMAL}"
