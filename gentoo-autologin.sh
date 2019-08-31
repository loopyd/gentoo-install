#!/bin/bash

AUTOLOGIN_USERNAME="$1"
ATUOLOGIN_COMMAND="$2"

if [[ "$ATUOLOGIN_COMMAND x" == " x" ]]; then
	>&2 echo 'No login command specified, please check your gentoo-autologin.sh arguments'
	exit
fi
if [[ "$AUTOLOGIN_USERNAME x" == " x" ]]; then
	>&2 echo 'No username specified, please check your gentoo-autologin.sh arguments'
fi

function enable_autologin () {

cat <<EOFDOC > /etc/conf.d/agetty-autologin
getty_options="--autologin $AUTOLOGIN_USERNAME --noclear"
EOFDOC
	cp /etc/shadow /etc/shadow.bak
	sed -i -e 's/^root:\*/root:/' /etc/shadow
	rc-config delete agetty.tty1
	cp /etc/init.d/agetty.tty1 /root/agetty.tty1.backup
	mv /etc/init.d/agetty.tty1 /etc/init.d/agetty-autologin.tty1 
	rc-update add agetty-autologin.tty1 default 
}

function disable_autologin () {
	rm -f /etc/shadow
	cp /etc/shadow.bak /etc/shadow
	rc-config delete agetty-autologin.tty1
	rm -f /etc/init.d/agetty-autologin.tty1 
	mv /root/agetty.tty1.backup /etc/init.d/agetty.tty1
	rc-update add agetty.tty1 default
}

case "$ATUOLOGIN_COMMAND" in
	enable)
		enable_autologin
		;;
	disable)
		disable_autologin
		;;
	*)
		>&2 echo "Invalid autologin command (${ATUOLOGIN_COMMAND}) specified"
		;;
esac
