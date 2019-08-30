#!/bin/bash

rm -f ~/debug.log
exec 5> ~/debug.log
set -x
BASH_XTRACEFD="5"
. ./gentoo-install.sh
set +x
exec 5>/dev/null
nano ~/debug.log