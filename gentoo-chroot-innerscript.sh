#!/bin/bash

env-update
source /etc/profile
export PS1="(chroot) $PS1"

. /root/gentoo-config.sh
. /root/gentoo-wrappers.sh

#- INITIAL WEBRSYNC -#
emerge-webrsync
eselect profile set 23
emerge app-crypt/openpgp-keys-gentoo-release

#- LOCALE/TIME ZONE -#
emerge --config sys-libs/timezone-data
locale-gen

#- GENTOO ESELECT REPOSITORY -#
emerge app-eselect/eselect-repository
mkdir -p /etc/portage/repos.conf/
eselect repository enable gentoo
echo 'Syncing repository...'
emerge --sync
emerge flaggie

#- KERNEL -#
# NEW: All of this now automatic and in the wrapper, whew...
. /root/gentoo-scriptwrapper.sh 'Compiling kernel' '. /root/gentoo-kernelcompile.sh'

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
%sudo ALL=(ALL) ALL

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

useradd -m -G wheel,video,audio,root,sys,disk,adm,sddm,bin,daemon,tty,portage,console,plugdev,usb,cdrw,cdrom,input,lp,uucp -s /bin/bash $USERNAME
echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME

#- ENABLE SERVICES -#
# Without configuring these to start, we won't get past login
# I went through a broken system's dmesg | grep for a little
# while to get this list of needy, red headed stepchildren.
#
rc-update add lvm boot
rc-update add mdraid boot
rc-update add alsasound boot
rc-update add dbus boot
rc-update add elogind boot
rc-update add syslog-ng default 
rc-update add cronie default
rc-update add acpid default
rc-update add NetworkManager default
rc-update add sshd default
rc-update add bootchart2 default

# . /root/gentoo-scriptwrapper.sh 'Enabling autologin' '. /root/gentoo-autologin.sh "root" "enable"'
