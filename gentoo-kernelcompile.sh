#!/bin/bash

#- THE KINKY BITS -#
# The pajamas are comin' off!
emerge =sys-kernel/linux-headers-5.1::gentoo =sys-kernel/ck-sources-5.1.7::gentoo

cd /usr/src/linux
make clean && make mrproper

#- KERNEL CONFIG -#
cp -f /root/kernel-config.txt /usr/src/linux/.config
make -j8
make modules_install
make install
cd ~