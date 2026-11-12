#!/bin/sh
# Load MPC Remote inside MPC until the next reboot: a drop-in in /run (gone on reboot), then an MPC restart.
# If MPC doesn't come back stable, the drop-in is taken out and MPC restarted without the addin.
D=/data/mpc-remote
U=/run/systemd/system/acvs.service.d
DROP=$U/90-mpc-remote.conf
SO=$D/mpc_remote_addin.so

loaded() { tr '\0' '\n' < "/proc/$(pidof MPC)/environ" 2>/dev/null | grep -q "^LD_PRELOAD=.*mpc_remote_addin.so"; }

if [ "$(pidof MPC)" ] && loaded; then
    echo "MPC Remote is already loaded in MPC"
    exit 0
fi
[ -f "$SO" ] || { echo "no $SO"; exit 1; }
[ -f "$D/mpc_remote_addin.conf" ] || { echo "no settings file in $D"; exit 1; }

[ -f "$D/launch-with-remote.sh" ] || { echo "no $D/launch-with-remote.sh"; exit 1; }

sh "$D/stop.sh"
mkdir -p "$U"
# MPC starts through launch-with-remote.sh, which adds the addin to Hakai's launcher (Hakai replaces LD_PRELOAD)
cat > "$DROP" <<EOF
[Service]
ExecStart=
ExecStart=/bin/sh $D/launch-with-remote.sh
EOF
systemctl daemon-reload
echo "restarting MPC"
systemctl restart acvs

i=0
while ! netstat -tln | grep -q ':6720 ' && [ $i -lt 90 ]; do sleep 1; i=$((i+1)); done
echo "port 6720 after ${i}s: $(netstat -tln | grep -c ':6720 ')"
P=$(pidof MPC)
sleep 40
OK=1
[ -n "$P" ] && [ "$(pidof MPC)" = "$P" ] || { echo "MPC restarted or stopped by itself"; OK=0; }
netstat -tln | grep -q ':6720 ' || { echo "the addin isn't answering"; OK=0; }
[ "$(systemctl show acvs -p NRestarts)" = "NRestarts=0" ] || { echo "acvs: $(systemctl show acvs -p NRestarts)"; OK=0; }
loaded || { echo "the addin isn't in MPC's LD_PRELOAD"; OK=0; }
if [ $OK = 1 ]; then
    echo "MPC Remote loaded in MPC, pid $P"
    exit 0
fi

echo "ROLLING BACK"
rm -f "$DROP"
rmdir "$U" 2>/dev/null
systemctl daemon-reload
systemctl reset-failed acvs
systemctl restart acvs
sleep 10
echo "MPC pid after rollback: $(pidof MPC), acvs $(systemctl is-active acvs)"
exit 1
