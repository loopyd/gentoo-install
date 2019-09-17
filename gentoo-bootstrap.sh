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
emerge --deep --newuse app-portage/eix app-portage/gentoolkit app-portage/genlop app-portage/portage-utils app-portage/layman 
layman --fetch --add kde

#- THIS PART SUCKS -#
# Its the reason the script takes 9 hours.  Emerge KDE, don't shit yourself, okay?
# Get up and move around if ya need to.  Beat off to my videos.  Or somethin...
#
echo 'Installing display manager...'
emerge --deep --newuse x11-misc/sddm 

echo 'Installing KDE Plasma...'

# https://bugs.gentoo.org/692352
# unit test 2019/09/17 failed with build error in =dev-qt/qtwebengine-5.12.4
# ../../3rdparty/chromium/third_party/webrtc/rtc_base/physicalsocketserver.cc:74:27: note: suggested alternative: 'SIOCGARP'
#   int ret = ioctl(socket, SIOCGSTAMP, &tv_ioctl);
#
# The following patch is applied to kernel headers >= 5.2 .
#
mkdir --parents /etc/portage/patches/dev-qt/qtwebengine-5
cat <'EOF' > /etc/portage/patches/dev-qt/qtwebengine-5.12.4/linux-headers-5.2.patch 
--- a/src/3rdparty/chromium/third_party/webrtc/rtc_base/physicalsocketserver.cc
+++ b/src/3rdparty/chromium/third_party/webrtc/rtc_base/physicalsocketserver.cc
@@ -67,6 +67,7 @@ typedef void* SockOptArg;
 #endif  // WEBRTC_POSIX
 
 #if defined(WEBRTC_POSIX) && !defined(WEBRTC_MAC) && !defined(__native_client__)
+#include <linux/sockios.h>
 
 int64_t GetSocketRecvTimestamp(int socket) {
   struct timeval tv_ioctl;
EOF
#
# The thread also mentions enabling jumbo-build, that's done here to speed up
# compilation of the package as an additional (unrealted) step.
#
# This reduce build time from 17 hours to 9 for tmpfs portage with > 10GB dedicated
# RAM and at least 7 CPU threads.
#
cat <'EOF' >> /etc/portage/package.use/zz-autounmask
>=dev-qt/qtwebengine-5.12.4 jumbo-build system-ffmpeg system-icu
EOF

emerge --deep --newuse virtual/latex-base kde-plasma/plasma-meta kde-plasma/kdeplasma-addons kde-apps/kde-apps-meta
emerge --changed-use kde-plasma/systemsettings
emerge --deep --newuse @kde-frameworks @kdeutils @kde-baseapps @kde-applications @kdesdk @kdepim @kdemultimedia @kdegraphics @kdegames @kdeaccessibility @kdenetwork @kdeedu @kdeadmin x11-plugins/pidgin-indicator net-im/pidgin

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
rc-update add xdm default

#- WORLD SYNC -#
echo 'Syncing @world...'
emerge @world

#- ROOT PASSWORD -#
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root

#- Drop exection back to the bootstrap wrapper. -#
rm -f /root/gentoo-bootstrap.sh
. /root/gentoo-scriptwrapper.sh 'Resetting autologin configuration' '/root/gentoo-autologin.sh "root" "disable"'
reboot