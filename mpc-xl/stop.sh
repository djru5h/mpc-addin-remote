#!/bin/sh
# Stop MPC Remote. MPC keeps running.
P=$(pidof mpc-remote)
if [ -z "$P" ]; then
    echo "MPC Remote isn't running"
    exit 0
fi
kill $P
sleep 1
pidof mpc-remote > /dev/null && echo "MPC Remote STILL RUNNING" || echo "MPC Remote stopped"
