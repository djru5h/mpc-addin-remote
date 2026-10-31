#!/bin/sh
# Start MPC Remote beside MPC, as its own process. Nothing runs at boot on the XL, so this is run by hand after each reboot.
D=/data/mpc-remote
cd "$D" || exit 1
if netstat -tln | grep -q ':6720 '; then
    echo "MPC Remote already running"
    exit 0
fi
MPC_REMOTE_ADDIN_CONF="$D/remote.conf" nohup ./mpc-remote ./mpc_remote_addin.so < /dev/null > /tmp/mpc-remote.log 2>&1 &
i=0
while ! netstat -tln | grep -q ':6720 ' && [ $i -lt 10 ]; do sleep 1; i=$((i+1)); done
if netstat -tln | grep -q ':6720 '; then
    echo "MPC Remote started"
else
    echo "MPC Remote DID NOT START:"
    cat /tmp/mpc-remote.log
    exit 1
fi
