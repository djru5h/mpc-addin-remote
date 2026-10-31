# MPC Remote on the Akai MPC XL (Gen 2)

The XL's screen in a web browser: see it live, click and drag with a mouse, and press hardware buttons from the page.

This is a setup for the XL on top of [mpc-addin-remote](https://github.com/jacob-sabella/mpc-addin-remote) by jacob-sabella, using the Gen 2 build and button work from [sd88me's fork](https://github.com/sd88me/mpc-addin-remote). This folder adds the XL's settings, a partial button list, and scripts to run it on a read-only system drive. Unofficial; not made or supported by Akai or inMusic.

**Tested on one MPC XL running MPC 3.9.1, by one person.** Treat it as a test build.

## Before you start

- **You need root SSH on the XL.** Nothing here provides that. On 3.9.1 it comes from a community USB stick; 3.10 restricts USB autorun, so that route may not work there.
- **It runs as root and has no login.** It listens on the XL only, and you reach it through an SSH tunnel. Don't set `bind=0.0.0.0` on a network you don't trust.
- **Clicks are real.** They do what a finger would, including changing projects and settings.

## What works

| | Standalone | Loaded inside MPC |
|---|---|---|
| Live screen | Yes | Yes |
| Mouse tap | Yes | Yes |
| Hardware buttons | No | Yes, once taught |
| Touches MPC when started | No | Restarts MPC, losing anything unsaved |
| A crash can take MPC down | Shouldn't | **Yes** |
| After a reboot | Start it again | Load it again, which restarts MPC |

Typing can't work on the XL, because its kernel has no `uinput`. Use the MPC's on-screen keyboard.

Not tested on the XL: dragging, knob turning, pads, Q-Links, and the MCP endpoint (off in these settings). Audio impact hasn't been measured. Streaming took about 11% of one core at 5 frames per second, and these settings use 10.

## Install

1. Download the zip from this repo's Releases and unpack it, or build it yourself (below).
2. Copy the folder to the XL as `/data/mpc-remote`:
   ```sh
   scp -O -r MPC-Remote-XL root@<xl-address>:/data/mpc-remote
   ssh root@<xl-address> chmod 755 /data/mpc-remote/mpc-remote
   ```
3. On Windows, edit the `MPC_HOST` line at the top of `MPC XL Remote.bat` to your XL's address, then double-click it. It opens the page at `http://localhost:6721`. Elsewhere, run the scripts over SSH and open the tunnel yourself:
   ```sh
   ssh -N -L 6721:127.0.0.1:6720 root@<xl-address>
   ```

Nothing starts at boot, and the system drive isn't changed. After a reboot, the shortcut asks before restarting MPC.

| Script | What it does |
|---|---|
| `start.sh` / `stop.sh` | Run or stop the standalone copy |
| `load-into-mpc.sh` | Load it inside MPC until the next reboot, using a setting in `/run`. Restarts MPC, and takes the setting out again if MPC isn't stable 40 seconds later |
| `unload-from-mpc.sh` | Take it out of MPC. Restarts MPC |
| `is-loaded.sh` | Exit 0 if it's loaded inside MPC |

## Buttons

Load it inside MPC, then use **Teach a button** on the page: type a name, click **Learn**, and press the button on the XL within 15 seconds. Names and notes are saved in `/data/mpc-remote/buttons.conf`.

`buttons.conf` here has the six I've taught: MAIN, PLAY, STOP, REC, START and ODB. Those all match the Live III's notes, but don't assume its other buttons match the XL's.

## XL settings that differ

- `screen_rotate=270`. The automatic setting shows the XL's screen upside down.
- `/etc` is on the read-only system drive, so the normal addin installer shouldn't work here. That's why these scripts use `/run` instead.

## Undo

If MPC starts crashing, reboot the XL. The setting in `/run` is wiped, and MPC starts without the addin. To remove everything, unload or reboot, run `stop.sh`, then delete `/data/mpc-remote`.

## Build

```sh
./build-aarch64.sh     # needs Docker with QEMU for arm64
```

The zip's `mpc_remote_addin.so` is `build/aarch64/mpc_remote_addin.so`, and its `mpc-remote` is `build/aarch64/standalone`, renamed.

MIT, see [LICENSE](../LICENSE).
