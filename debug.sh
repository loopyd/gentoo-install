#!/bin/bash

rm -f ~/debug.log
exec 5> ~/debug.log
set -x
BASH_XTRACEFD="5"
. ./setup.sh
set +x
exec 5>/dev/null
nano ~/debug.log