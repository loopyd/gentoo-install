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

cat <<EOFDOC > /etc/init.d/agetty-autologin
getty_options="--autologin $AUTOLOGIN_USERNAME --noclear"
EOFDOC
	sed -i -e 's/^root:\*/root:/' /etc/shadow
	rc-config delete agetty
	cp /etc/init.d/agetty /root/agetty.backup
	rc-update add agetty-autologin default 
	#- MAKE THE KICKER EXECUTABLE -#
# This script will not be made executable until reboot time.
cat <<INNERSCRIPT > /etc/profile.d/gentoo-bootkicker.sh
#!/bin/bash
/root/gentoo-bootstrap.sh
reboot
INNERSCRIPT
chmod +x /etc/profile.d/gentoo-bootkicker.sh
}

function disable_autologin () {
	rc-config delete agetty-autologin
	rm -f /etc/init.d/agetty-autologin 
	mv /root/agetty.backup /etc/init.d/agetty
	rc-update add agetty default
}

case "$ATUOLOGIN_COMMAND" in
	*enable*)
		enable_autologin
		;;
	*disable*)
		disable_autologin
		;;
	*)
		>&2 echo "Invalid autologin command (${ATUOLOGIN_COMMAND}) specified"
		;;
esac
