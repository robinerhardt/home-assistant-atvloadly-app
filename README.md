# atvloadly Home Assistant OS App

This repository contains a local/custom Home Assistant app for
[bitxeno/atvloadly](https://github.com/bitxeno/atvloadly). It is designed for a
Raspberry Pi running 64-bit Home Assistant OS on the same LAN or VLAN as the
Apple TV.

## Verified upstream version

- Upstream repository checked on August 24, 2026, at commit
  `e42514145dd8bdee18f89513625ec0d9267cf4f3`.
- Pinned stable release: `v0.4.8`.
- Pinned multi-architecture image digest:
  `sha256:f459b916835c724a3ed9e55a450e493f6129b377f9467759338c64e7970af947`.
- The image supports `linux/arm64` and `linux/amd64`.
- `armv7`/32-bit is not built by the upstream Dockerfile, release workflow, or
  binary dependencies and is therefore intentionally unsupported.

## Installation in Home Assistant (HASS)

### Requirements

- Home Assistant OS with access to **Settings > Apps**. Home Assistant
  Container and Home Assistant Core do not support apps.
- A 64-bit `aarch64` (for example, Raspberry Pi 4/5) or `amd64` system.
- Home Assistant and the Apple TV must be on the same LAN/VLAN, with mDNS and
  direct connections between both devices allowed.
- Internet access during installation so Supervisor can download and build the
  pinned container image.

### Recommended: install this app repository

1. In Home Assistant, open **Settings > Apps > Install app**.
2. Open the three-dot menu in the upper-right corner and select
   **Repositories**.
3. Add this repository URL:

   ```text
   https://github.com/robinerhardt/home-assistant-atvloadly-app
   ```

4. Close the repository dialog. Refresh the browser if the new repository does
   not appear immediately.
5. Select **atvloadly Home Assistant App**, then select **Install**. The first
   installation builds the app locally and can take several minutes.
6. When the installation has finished, enable **Start on boot** and optionally
   **Watchdog**, then select **Start**.
7. Select **Open Web UI**, or open
   `http://<HOME_ASSISTANT_IP>:5533` directly.

No changes to `configuration.yaml` and no Home Assistant restart are required.

### Alternative: install as a local app

Use this method if the repository cannot be added through the app store.

1. Download this repository as a ZIP and extract it on your computer. Home
   Assistant cannot install the ZIP file directly.
2. Install the **Samba share** app, or another app that provides access to the
   Home Assistant app directory.
3. Copy only the extracted `atvloadly` folder to `/addons/atvloadly` on Home
   Assistant OS. The Samba share for this directory is named `local_apps` in
   current Home Assistant versions and `addons` in older versions.
4. Open **Settings > Apps > Install app**, open the three-dot menu, and select
   **Check for updates** or **Reload**.
5. Select **atvloadly** under **Local apps**, then install and start it.
6. Enable **Start on boot** and optionally **Watchdog**, then select
   **Open Web UI**.

### First use

1. On the Apple TV, open **Settings > Remotes and Devices > Remote App and
   Devices** and leave this screen open.
2. In the atvloadly web UI, select the Apple TV and complete pairing.
3. Use a separate Apple ID for signing instead of your everyday primary Apple
   ID. Upstream currently does not support app-specific Apple passwords.

If the app or Apple TV is not shown, see the troubleshooting section in
[`atvloadly/DOCS.md`](atvloadly/DOCS.md).

## Why these permissions are used

| Setting | Value | Reason |
|---|---:|---|
| `host_network` | `true` | Bonjour/mDNS uses multicast on UDP port 5353. Incoming LAN multicast does not reliably reach an app through the regular Supervisor bridge network. atvloadly also connects directly to the TCP ports advertised by the Apple TV. |
| `host_dbus` | `false` | The app starts its own private D-Bus and Avahi services, keeping the host D-Bus and other host services hidden. |
| `privileged` | `[]` | No additional Linux capabilities are required. The upstream `usbmuxd2` process runs with `--nousb`, and no USB devices are passed through. |
| `full_access` | `false` | Docker privileged mode and full hardware access are unnecessary. |
| Supervisor/HA/Docker API | `false` | atvloadly does not need access to these APIs. |
| AppArmor | `true` | Standard container isolation remains enabled. |
| Ingress | `false` | The upstream frontend uses absolute `/api` and `/ws` paths and is not reliable under a Home Assistant Ingress subpath. |

The upstream Docker example requests `seccomp:unconfined`. Home Assistant
Supervisor already starts app containers with `seccomp=unconfined`, so this
does not require disabling protection mode or enabling `full_access`.

## Network, ports, and persistence

- TCP 5533: atvloadly web UI, API, WebSockets, and MCP endpoint.
- UDP 5353: Avahi mDNS/Bonjour discovery. Because the app uses host
  networking, this is not configured as a separate Docker port mapping.
- Dynamic Apple TV ports: discovered through Bonjour and contacted by the
  app. A VLAN firewall must allow these outbound connections if applicable.
- `/data`: persistent storage managed automatically by Supervisor. It contains
  the configuration, pairing files, Apple ID and certificate data, IPA files,
  database, and logs.

## Security warning

atvloadly does not provide Home Assistant authentication. TCP port 5533 must be
accessible only from a trusted LAN and must never be forwarded from the
internet. Upstream also includes an unauthenticated `/ws/tty` endpoint. This
wrapper places a blocking process in front of `bash`, preventing that endpoint
from starting a shell. The remaining atvloadly UI and API are still available
on the LAN without authentication.

Use a separate Apple ID for atvloadly. Upstream currently does not support
app-specific Apple passwords.

## Updating

For a new atvloadly release, verify and update the image tag and multi-arch
digest in `atvloadly/Dockerfile`, then increase the app version in
`atvloadly/config.yaml`. Avoid using `latest` so local builds remain
reproducible.

## Validation limits

The YAML files, shell scripts, permissions, security flags, and expected
Supervisor directory structure can be validated locally. End-to-end testing of
Bonjour discovery, pairing, signing, and installation requires a real Home
Assistant OS device and an Apple TV in pairing mode.
