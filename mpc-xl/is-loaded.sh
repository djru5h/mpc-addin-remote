#!/bin/sh
# Exit 0 if MPC Remote is loaded inside the running MPC, 1 if not (a reboot takes it out).
P=$(pidof MPC)
[ -n "$P" ] || exit 1
tr '\0' '\n' < "/proc/$P/environ" | grep -q '^LD_PRELOAD=.*mpc_remote_addin.so'
