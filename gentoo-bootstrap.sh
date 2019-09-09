#!/bin/bash
rm -f /etc/profile.d/gentoo-bootkicker.sh
env-update

. /root/gentoo-config.sh

#- STRAPPIN BOOTS -#
#- Bootstrap the system with the new make.conf and profile -#
# This is the recompile the compiler gag we toss around at work.
echo 'Running bootstrapper to optimize compilers...'

/usr/portage/scripts/bootstrap.sh
emerge -e system

#- PORTAGE SHIT -#
# Its the good kind.  Useful portage tools.  Also, use layman to add the kde group, we'll need it
# later on...
echo 'Installing portage extensions...'
emerge app-portage/eix app-portage/gentoolkit app-portage/genlop app-portage/portage-utils app-portage/layman 
layman --fetch --add kde

#- ALSA AND PULSE -#
echo 'Installing alsa and pulseaudio...'
emerge alsa-utils media-libs/alsa-lib alsa-plugins alsa-tools pulseaudio

#- THIS PART SUCKS -#
# Its the reason the script takes 9 hours.  Emerge KDE, don't shit yourself, okay?
# Get up and move around if ya need to.  Beat off to my videos.  Or somethin...
#
echo 'Installing display manager...'
emerge sys-fs/udisks sys-auth/polkit sys-auth/consolekit x11-misc/sddm 
echo 'Installing KDE Plasma...'
emerge kde-plasma/plasma-meta kde-plasma/kdeplasma-addons 
emerge --changed-use kde-plasma/systemsettings
echo 'Upgrade to Plasma 5 stable / apps...'
emerge @kde-plasma @kde-frameworks @kdeutils @kde-baseapps @kde-applications @kdesdk @kdepim @kdemultimedia @kdegraphics @kdegames @kdeaccessibility @kdenetwork @kdeedu @kdeadmin x11-plugins/pidgin-indicator net-im/pidgin

#- SUDO OFF, SUDO ON -#
# Its like a flavor of martial arts or somethin
#
emerge app-admin/sudo 

cat <<'EOFDOC' > /etc/sudoers
## sudoers file.
##
## This file MUST be edited with the 'visudo' command as root.
## Failure to use 'visudo' may result in syntax or file permission errors
## that prevent sudo from running.
##
## See the sudoers man page for the details on how to write a sudoers file.
##

##
## Host alias specification
##
## Groups of machines. These may include host names (optionally with wildcards),
## IP addresses, network numbers or netgroups.
# Host_Alias    WEBSERVERS = www1, www2, www3

##
## User alias specification
##
## Groups of users.  These may consist of user names, uids, Unix groups,
## or netgroups.
# User_Alias    ADMINS = millert, dowdy, mikef

##
## Cmnd alias specification
##
## Groups of commands.  Often used to group related commands together.
# Cmnd_Alias    PROCESSES = /usr/bin/nice, /bin/kill, /usr/bin/renice, \
#               /usr/bin/pkill, /usr/bin/top
# Cmnd_Alias    REBOOT = /sbin/halt, /sbin/reboot, /sbin/poweroff

##
## Defaults specification
##
## You may wish to keep some of the following environment variables
## when running commands via sudo.
##
## Locale settings
# Defaults env_keep += "LANG LANGUAGE LINGUAS LC_* _XKB_CHARSET"
##
## Run X applications through sudo; HOME is used to find the
## .Xauthority file.  Note that other programs use HOME to find   
## configuration files and this may lead to privilege escalation!
# Defaults env_keep += "HOME"
##
## X11 resource path settings
Defaults env_keep += "XAPPLRESDIR XFILESEARCHPATH XUSERFILESEARCHPATH"
##
## Desktop path settings
Defaults env_keep += "QTDIR KDEDIR"
##
## Allow sudo-run commands to inherit the callers' ConsoleKit session
Defaults env_keep += "XDG_SESSION_COOKIE"
##
## Uncomment to enable special input methods.  Care should be taken as
## this may allow users to subvert the command being run via sudo.
# Defaults env_keep += "XMODIFIERS GTK_IM_MODULE QT_IM_MODULE QT_IM_SWITCHER"
##
## Uncomment to use a hard-coded PATH instead of the user's to find commands
# Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
##
## Uncomment to send mail if the user does not enter the correct password.
# Defaults mail_badpass
##
## Uncomment to enable logging of a command's output, except for
## sudoreplay and reboot.  Use sudoreplay to play back logged sessions.
# Defaults log_output
# Defaults!/usr/bin/sudoreplay !log_output
# Defaults!/usr/local/bin/sudoreplay !log_output
# Defaults!REBOOT !log_output

##
## Runas alias specification
##

##
## User privilege specification
##
root ALL=(ALL) ALL

## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL) ALL

## Same thing without a password
# %wheel ALL=(ALL) NOPASSWD: ALL

## Uncomment to allow members of group sudo to execute any command
# %sudo ALL=(ALL) ALL

## Uncomment to allow any user to run sudo if they know the password
## of the user they are running the command as (root by default).
# Defaults targetpw  # Ask for the password of the target user
# ALL ALL=(ALL) ALL  # WARNING: only use this together with 'Defaults targetpw'

## Read drop-in files from /etc/sudoers.d
## (the '#' here does not indicate a comment)
#includedir /etc/sudoers.d
EOFDOC

#- USER ACCOUNT SETUP -#
echo 'Setting up user account: '"$USERNAME"
useradd $USERNAME -g users -G wheel,video,audio,root,sys,disk,adm,sddm,bin,daemon,tty,portage,console,plugdev,usb,cdrw,cdrom,input,lp,uucp -d /home/$USERNAME -s /bin/bash 
mkdir /home/$USERNAME
cp -a /etc/skel/. /home/$USERNAME/.
chown -R $USERNAME /home/$USERNAME
echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME

#- ROOT PASSWORD -#
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root

#- DISPLAY MANAGER CONFIG -#
echo 'Configuring X session for KDE...'
cat <<'EOFDOC' > /etc/env.d/90xsession
XSESSION="KDE-5"
EOFDOC
cat <<'EOFDOC' > /home/$USERNAME/.xinitrc
exec ck-launch-session dbus-launch --sh-syntax --exit-with-session startkde
EOFDOC

echo 'Copying X session config to skeleton directory...'
cp /home/$USERNAME/.xinitrc /etc/skel
chown $USERNAME /home/$USERNAME/.xinitrc

echo 'Configuring SDDM with kwallet password authentication module...'
cat <<'EOFDOC' > /etc/pam.d/sddm
#%PAM-1.0

auth            include         system-login
-auth           optional        pam_gnome_keyring.so
-auth           optional        pam_kwallet5.so

account         include         system-login

password        include         system-login
-password       optional        pam_gnome_keyring.so use_authtok

session         optional        pam_keyinit.so force revoke
session         include         system-login
-session        optional        pam_gnome_keyring.so auto_start
-session        optional        pam_kwallet5.so auto_start
EOFDOC

echo 'Adding sddm to video group to prevent performance issues..'
usermod -a -G video sddm
echo 'Setting default display manager to sddm'
cat <<'EOFDOC' > /etc/conf.d/xdm
DISPLAYMANAGER="sddm"
EOFDOC

#- KDE SERVICES -#
echo 'Enabling KDE Plasma services...'
rc-update add consolekit default
rc-update add dbus boot
rc-update add udisks default
rc-update add xdm default

echo 'Enabling alsa services...'
rc-update add alsasound boot

#- WORLD SYNC -#
echo 'Syncing @world...'
emerge @world

#- Drop exection back to the bootstrap wrapper. -#
rm -f /root/gentoo-bootstrap.sh
. /root/gentoo-scriptwrapper.sh 'Resetting autologin configuration' '/root/gentoo-autologin.sh "root" "disable"'
reboot