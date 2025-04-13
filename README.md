# status

## Minimal System Status Script for DWM

This is a minimal shell based real-time [dwm](https://dwm.suckless.org/) bar. It's especially useful for ThinkPad laptops with PowerBridge (dual battery) configurations and for users of [Mullvad VPN](https://mullvad.net/).`dwm` status bar.

## Features

- **Mullvad VPN**: Detects connection status and shows current location using `curl` to `am.i.mullvad.net`.
- **Network Status**: Shows IP addresses for all interfaces or offline state.
- **Battery**: Smart handling of dual-battery setups (e.g., ThinkPads with PowerBridge), showing both percentage and charging state.
- **CPU & Power**: Displays temperature, estimated power draw, and fan speed.
- **Audio**: Alsa based volume level with mute indicator.

## Requirements

Make sure these tools are installed and working:

- [`xsetroot`](https://man.archlinux.org/man/xsetroot.1) – updates the DWM status bar
- [`acpi`](https://sourceforge.net/projects/acpiclient/) – battery and thermal info
- [`curl`](https://curl.se/) – used for Mullvad location queries
- [`sensors`](https://github.com/lm-sensors/lm-sensors) – provides CPU temps and fan speeds
- [`bc`](https://www.gnu.org/software/bc/) – command-line calculator for formatting values
- [`amixer`](https://www.alsa-project.org/wiki/Amixer) – volume and mute status via ALSA
- [`ip`](https://man.archlinux.org/man/ip.8) – part of `iproute2`, for checking network interfaces
- [`mullvad`](https://github.com/mullvad/mullvadvpn-app) (optional) – CLI tool for checking VPN connecti

## Usage

Run the script in the background from your `.xinitrc` or window manager startup file:

```bash
/path/to/status.sh &
```

It will update the DWM status bar every few seconds.

## Customization
The script is designed to be easy to modify. You can add or remove sections based on your needs by editing the main loop and update functions.
