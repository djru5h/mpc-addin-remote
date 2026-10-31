#!/bin/sh
# Take MPC Remote out of MPC without a reboot: remove the /run drop-in, then restart MPC. The standalone copy can run again afterwards.
U=/run/systemd/system/acvs.service.d
rm -f "$U/90-mpc-remote.conf"
rmdir "$U" 2>/dev/null
systemctl daemon-reload
systemctl reset-failed acvs
systemctl restart acvs
sleep 10
echo "MPC pid: $(pidof MPC), acvs $(systemctl is-active acvs)"
