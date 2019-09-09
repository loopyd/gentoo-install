#!/bin/bash

rm -f ~/debug_trace.log 2>/dev/null
rm -f ~/debug_std.log 2>/dev/null
exec 5> ~/debug_trace.log
exec 2> ~/debug_std.log
set -x
BASH_XTRACEFD="5"
. ./setup.sh
set +x
exec 5>/dev/null
exec 2>&1