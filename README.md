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

## Install as a local app

1. Install the **Samba share** app or a suitable SSH/file editor app in
   Home Assistant.
2. Extract the downloaded ZIP file on your computer.
3. Copy only the `atvloadly` subfolder to `/addons/atvloadly` on Home Assistant
   OS. In current Samba versions, this share is named `local_apps`; older
   versions call it `addons`.
4. Open **Settings > Apps**.
5. Open the menu in the upper-right corner and select **Check for updates** or
   **Reload**.
6. Open **atvloadly** under **Local apps** and select **Install**. The first
   build downloads the pinned upstream image and two small Ubuntu packages.
7. Start the app and optionally enable **Start on boot** and **Watchdog**.
8. Open the web UI at `http://<HOME_ASSISTANT_IP>:5533`.

Home Assistant cannot install the ZIP directly. Extract it first and copy the
folder as described above.

## Install as a custom GitHub repository

1. Upload the complete contents of this folder to the root of a public GitHub
   repository. `repository.yaml` and the `atvloadly` folder must be located
   directly in the repository root.
2. Open **Settings > Apps > Install app**, open the menu, and select
   **Repositories**.
3. Add the URL of your GitHub repository and install the displayed app.

Recommended repository name:

```text
home-assistant-atvloadly-app
```

Recommended GitHub description:

```text
A custom Home Assistant OS app for atvloadly with Apple TV discovery via Avahi/mDNS. Supports ARM64 and AMD64.
```

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
