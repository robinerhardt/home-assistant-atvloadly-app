# atvloadly for Home Assistant

Run [atvloadly](https://github.com/bitxeno/atvloadly) as a third-party Home
Assistant app and manage sideloaded apps on an Apple TV from your local
network.

This repository is designed for 64-bit Home Assistant OS installations. It
provides local Apple TV discovery, persistent app data, safe default
permissions, and automatic updates for new atvloadly releases.

> [!IMPORTANT]
> Home Assistant and the Apple TV should be on the same LAN or VLAN. The web
> interface has no login of its own and must only be exposed to a trusted local
> network.

## Compatibility

| Requirement | Supported |
|---|---|
| Home Assistant OS | Yes |
| Home Assistant Supervised | Expected to work, but not the primary target |
| Home Assistant Container or Core | No app support |
| Raspberry Pi 4/5 with 64-bit Home Assistant OS (`aarch64`) | Yes |
| 64-bit Intel/AMD systems (`amd64`) | Yes |
| 32-bit Raspberry Pi systems (`armv7`) | No |

## Install

### One-click installation

[![Open your Home Assistant instance and add this app repository.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Frobinerhardt%2Fhome-assistant-atvloadly-app)

After adding the repository:

1. Open **Settings > Apps > Install app**.
2. Select **atvloadly** and choose **Install**.
3. Wait for the local build to finish. The first installation can take several
   minutes.
4. Enable **Start on boot** and, optionally, **Watchdog**.
5. Start the app and select **Open Web UI**.

No changes to Home Assistant's `configuration.yaml` and no Home Assistant
restart are required.

### Manual repository installation

If the button does not work:

1. Open **Settings > Apps > Install app**.
2. Open the three-dot menu and select **Repositories**.
3. Add:

   ```text
   https://github.com/robinerhardt/home-assistant-atvloadly-app
   ```

4. Close the dialog and refresh the app store.
5. Install **atvloadly**.

## Pair your Apple TV

1. On the Apple TV, open **Settings > Remotes and Devices > Remote App and
   Devices** and leave this screen open.
2. Open the atvloadly web interface from the Home Assistant app page. You can
   also use `http://<HOME_ASSISTANT_IP>:5533`.
3. Select the Apple TV and complete the pairing process.
4. Use a separate Apple ID for signing instead of your everyday primary Apple
   ID. atvloadly currently does not support app-specific Apple passwords.

## Configuration and data

The app creates a user-editable atvloadly configuration file here:

```text
addon_configs/<repository-id>_atvloadly/config.yaml
```

For a local app installation, the directory is named `local_atvloadly`. You
can access it with Samba, Studio Code Server, or an SSH app that exposes the
`addon_configs` directory.

Stop atvloadly before editing the file and start it again afterward. The
default configuration is:

```yaml
server:
  work_dir: /data
log:
  log_file: /data/app.log
```

Credentials, certificates, pairing information, IPA files, the database, and
logs remain in the private `/data` directory. Home Assistant retains this data
during updates and includes it in app backups.

## Updates

Home Assistant shows an update when a new app version is available. Before
updating:

1. Create a Home Assistant app backup.
2. Open **Settings > Apps > atvloadly**.
3. Select **Update**.

If an update is not shown, open the app store's three-dot menu, select **Check
for updates**, and refresh the page.

Versions use the format `<atvloadly-version>-<app-revision>`. For example:

- `0.4.11-1` is the first app release based on atvloadly 0.4.11.
- `0.4.11-2` is a follow-up change to the Home Assistant wrapper.

See [Releases](https://github.com/robinerhardt/home-assistant-atvloadly-app/releases)
or the [changelog](atvloadly/CHANGELOG.md) for details.

## Troubleshooting

### The repository or app does not appear

Open the app store's three-dot menu, select **Check for updates**, and refresh
the browser. Also verify that the repository URL was entered without an extra
path or trailing filename.

### The Apple TV is not discovered

- Keep **Remote App and Devices** open on the Apple TV while pairing.
- Confirm that Home Assistant and the Apple TV are on the same LAN or VLAN.
- Make sure multicast DNS traffic on UDP port 5353 is not blocked.
- If VLAN firewall rules are in use, allow Home Assistant to reach the dynamic
  TCP ports advertised by the Apple TV.
- Restart the atvloadly app and check its log from the Home Assistant app page.

### The web interface does not open

- Try `http://<HOME_ASSISTANT_IP>:5533` directly.
- Confirm that TCP port 5533 is reachable from your trusted local network.
- Check the Home Assistant app log for startup errors.

More detailed operating notes are available in
[atvloadly/DOCS.md](atvloadly/DOCS.md).

## Security

atvloadly does not provide Home Assistant authentication. Never forward TCP
port 5533 to the internet and do not expose it through an unauthenticated
reverse proxy.

The upstream project also contains an unauthenticated `/ws/tty` endpoint. This
wrapper blocks the shell process used by that endpoint while keeping the
remaining atvloadly UI and API available on the local network.

Using a separate Apple ID for atvloadly is strongly recommended.

## Advanced installation: local app

Use this method only if the repository cannot be added through the Home
Assistant app store:

1. Download this repository as a ZIP and extract it on your computer.
2. Install the **Samba share** app or another app that provides access to the
   Home Assistant app directory.
3. Copy only the extracted `atvloadly` directory to
   `/addons/atvloadly` on Home Assistant OS. The Samba share is named
   `local_apps` in current Home Assistant versions and `addons` in older
   versions.
4. Open **Settings > Apps > Install app** and select **Check for updates** or
   **Reload** from the three-dot menu.
5. Install **atvloadly** from **Local apps**, then enable **Start on boot** and
   start it.

## Technical details

### Network and ports

- **TCP 5533:** web UI, API, WebSockets, and MCP endpoint.
- **UDP 5353:** Avahi mDNS/Bonjour discovery through host networking.
- **Dynamic Apple TV ports:** discovered through Bonjour and contacted directly
  by atvloadly.

### Permissions

| Setting | Value | Why it is needed |
|---|---:|---|
| `host_network` | `true` | Allows reliable Bonjour/mDNS multicast discovery and direct Apple TV connections. |
| `host_dbus` | `false` | The app uses its own private D-Bus and Avahi services instead of accessing the host D-Bus. |
| `privileged` | `[]` | No additional Linux capabilities are requested. |
| `full_access` | `false` | Docker privileged mode and unrestricted hardware access are not needed. |
| Supervisor, Home Assistant, and Docker APIs | `false` | The app does not need access to these APIs. |
| AppArmor | `true` | Standard container isolation remains enabled. |
| Ingress | `false` | The upstream frontend uses absolute `/api` and `/ws` paths and does not work reliably under an Ingress subpath. |

The upstream Docker example requests `seccomp:unconfined`. Home Assistant
Supervisor already starts app containers with this setting, so protection mode
does not need to be disabled and `full_access` is not required. The upstream
`usbmuxd2` process runs with `--nousb`; no USB devices are passed through.

## Automated maintenance

Renovate monitors the pinned `bitxeno/atvloadly` container image. When a new
upstream release is available, it creates one pull request that updates the
image tag, digest, and Home Assistant app version together. Passing atvloadly
update pull requests are merged automatically.

When a new app version reaches `main`, GitHub Actions creates a matching
`v<version>` tag and publishes categorized release notes. The exact upstream
image and digest remain pinned in `atvloadly/Dockerfile` for reproducible
builds.

## Project scope

This is an unofficial community wrapper and is not affiliated with Home
Assistant or the upstream atvloadly project. Report wrapper and installation
issues in this repository. Report atvloadly application issues to the
[upstream project](https://github.com/bitxeno/atvloadly/issues).
