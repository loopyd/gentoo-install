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

# cp -f ./kernel-config.txt $CHROOT_MOUNT/root/kernel-config.txt
cp -f ./*.sh $CHROOT_MOUNT/root
chmod +x $CHROOT_MOUNT/root/*.sh

echo 'Injecting omplete'
