#!/bin/sh
# MPC's start command while MPC Remote is loaded (set by load-into-mpc.sh through a /run drop-in, gone on reboot).
# MPC OS 3.10.1 with Hakai: /usr/bin/az01-launch-MPC is Hakai's launcher, which clears LD_PRELOAD and starts MPC with
# its own add-in list. So this runs a copy of that launcher with MPC Remote added LAST to the list: Hakai's driver hooks
# the same snd_rawmidi_* calls and passes them on with dlsym(RTLD_NEXT), and MPC Remote calls ALSA itself, so it has to
# come after Hakai's. If the launcher doesn't have the expected line (stock firmware, or Hakai changed it), the launcher
# runs unchanged with MPC Remote in LD_PRELOAD, the way it was loaded on 3.9.1.
L=/usr/bin/az01-launch-MPC
SO=/data/mpc-remote/mpc_remote_addin.so
T=/run/mpc-remote-launch.sh
A='PRELOAD="$USR/lib/hakai_driver.so $PRELOAD"'
if [ -f "$SO" ] && [ "$(grep -cxF "$A" "$L")" = 1 ]; then
    awk -v a="$A" -v so="$SO" '{ print } $0 == a { print "PRELOAD=\"$PRELOAD " so "\"" }' "$L" > "$T" &&
        exec sh "$T" "$@"
fi
[ -f "$SO" ] && export LD_PRELOAD="$SO"
exec "$L" "$@"
