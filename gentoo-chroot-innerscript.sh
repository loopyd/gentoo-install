#!/bin/bash

env-update
source /etc/profile
export PS1="(chroot) $PS1"

. /root/gentoo-config.sh

emerge-webrsync
. /root/gentoo-scriptwrapper.sh 'Automakeonf running' '. /root/gentoo-automakeconf.sh'

eselect profile set 23
emerge app-crypt/openpgp-keys-gentoo-release

#- LOCALE/TIME ZONE -#
# This doesn't completely fix emerge --sync.  Kindly never use emerge --sync.
# It stopped working December 2015 due to a critical bug dealing with hkdps
# links becoming deprecated by many of the mirrors.  Use emerge-webrsync
# like a good boy.
#
emerge --config sys-libs/timezone-data
locale-gen

. /root/gentoo-scriptwrapper.sh 'Compiling kernel' '/root/gentoo-kernelcompile.sh'

#- STRAPPIN BOOTS -#
#- Bootstrap the system with the new make.conf and profile -#
# This is the recompile the compiler gag we toss around at work.
echo 'Running bootstrapper to optimize compilers...'
/usr/portage/scripts/bootstrap.sh
emerge -e system

# This helps.  Its a recommended part of this.  Like lube.  You know.
# Gotta prepare, get it all nice and-
umount -v efivarfs && mount -v efivarfs 

#- IS IT XORG -#
# Or is it ZORBG! What ever it is, we need it for the graphics, and a display manager to look pretty and junk
# 
emerge x11-base/xorg-drivers x11-base/xorg-server x11-apps/xinit net-misc/x11-ssh-askpass x11-drivers/nvidia-drivers 
nvidia-xconfig
eselect opengl set nvidia

#- INITRAMFS -#
emerge dracut lvm2 linux-firmware sys-firmware/intel-microcode sys-boot/grub:2 xfsprogs e2fsprogs os-prober sys-fs/dosfstools sys-apps/usbutils sys-apps/hwinfo sys-fs/eudev sys-process/cronie app-admin/syslog-ng sys-apps/mlocate app-admin/logrotate acpi acpid 
dracut --kver $DRACUT_KVER -H --add "$DRACUT_MODULES" --add-drivers "$DRACUT_KERNEL_MODULES" -i /lib/firmware /lib/firmware --hostonly-cmdline --fstab --gzip --lvmconf --early-microcode --force /boot/initramfs-5.1.7-ck.img

#- GRUB -#
# Scrub-a-dub-grub
cat <<'EOFDOC' > /etc/default/grub
GRUB_DISTRIBUTOR="Gentoo"
GRUB_CMDLINE_LINUX="rd.auto=1"
EOFDOC
grub-install $OS_DEVICE --efi-directory=/boot/efi --target=x86_64-efi --no-floppy
grub-mkconfig -o /boot/grub/grub.cfg

#- CONFIGURE SERVICES -#
sed -i 's/threaded(yes)/threaded(no)/g' /etc/syslog-ng/syslog-ng.conf 
cat <<'EOFDOC' > /etc/syslog-ng/syslog-ng.conf
@version: 3.22
#
# Syslog-ng default configuration file for Gentoo Linux

# https://bugs.gentoo.org/426814
@include "scl.conf"

options {
    threaded(yes);
    chain_hostnames(no);

    # The default action of syslog-ng is to log a STATS line
    # to the file every 10 minutes.  That's pretty ugly after a while.
    # Change it to every 12 hours so you get a nice daily update of
    # how many messages syslog-ng missed (0).
    stats_freq(43200);
    # The default action of syslog-ng is to log a MARK line
    # to the file every 20 minutes.  That's seems high for most
    # people so turn it down to once an hour.  Set it to zero
    # if you don't want the functionality at all.
    mark_freq(3600);
};

source src { system(); internal(); };

destination messages { file("/var/log/messages"); };

# By default messages are logged to tty12...
destination console_all { file("/dev/tty12"); };
# ...if you intend to use /dev/console for programs like xconsole
# you can comment out the destination line above that references /dev/tty12
# and uncomment the line below.
#destination console_all { file("/dev/console"); };

log { source(src); destination(messages); };
log { source(src); destination(console_all); };
EOFDOC

#- ENABLE SERVICES -#
# Without configuring these to start, we won't get past login
# I went through a broken system's dmesg | grep for a little
# while to get this list of needy, red headed stepchildren.
#
rc-update add syslog-ng default 
rc-update add cronie default
rc-update add acpid default
rc-update add net.$ETH0_DEVICE default
rc-update add net.$ETH1_DEVICE default
rc-update add sshd default

#- ROOT PASSWORD -#
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root

. /root/gentoo-scriptwrapper.sh 'Enabling autologin' '. /root/gentoo-autologin.sh "root" "enable"'

#- MAKE THE KICKER EXECUTABLE -#
# This script will not be made executable until reboot time.
cat <<INNERSCRIPT /etc/profile.d/gentoo-bootkicker.sh
#!/bin/bash
. /root/gentoo-bootstrap.sh
rm -f /root/gentoo-bootstrap.sh
reboot
INNERSCRIPT
chmod +x /etc/profile.d/gentoo-bootkicker.sh