#!/bin/bash

#- UPDATE LIVECD -#
echo 'Fixing LiveCD portage installation...'
touch /etc/portage/package.use/use
emerge --sync
eselect profile set 5

echo 'yes' | etc-update --automode -3