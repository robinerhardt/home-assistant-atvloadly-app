# atvloadly for Home Assistant OS

This app runs the pinned atvloadly release with a private D-Bus and a
query-only Avahi service. This allows atvloadly to discover Apple TVs on the
same local network through Bonjour/mDNS.

## Usage

1. Start the app and select **Open Web UI**.
2. On the Apple TV, open **Settings > Remotes and Devices > Remote App and
   Devices** and leave this screen open.
3. The Apple TV should appear as an available pairing device in atvloadly.
4. Use a separate Apple ID for signing rather than your everyday primary Apple
   ID.

The web UI is available at `http://<HOME_ASSISTANT_IP>:5533`.

## Configuration file

The editable `config.yaml` is available in Home Assistant's app-specific
`addon_configs` directory. Use Samba, Studio Code Server, or an SSH app that
exposes this directory, then open the folder whose name ends in `_atvloadly`.
For a local installation, the folder is named `local_atvloadly`.

Stop the app before editing `config.yaml` and start it again afterward. Other
runtime data remains in the private app data directory.

## Security

- TCP port 5533 must only be reachable from a trusted LAN. Do not configure an
  internet-facing port forward.
- atvloadly does not include Home Assistant authentication for its web UI.
- This app prevents the upstream web-terminal endpoint from starting a
  shell.
- Apple ID data, pairing files, certificates, IPA files, SQLite data, and logs
  are stored in the private `/data` app directory. The private data and public
  app configuration are included in app backups.

## Troubleshooting

If the Apple TV does not appear:

1. Confirm that Home Assistant and the Apple TV are on the same un-routed LAN
   or VLAN.
2. Disable VPNs on the involved devices and reopen the Apple TV pairing screen.
3. Restart both the Apple TV and the app.
4. Check the app log for `Avahi discovery started` and entries containing
   `_remotepairing-manual-pairing._tcp`.
5. Confirm that no other service is using TCP port 5533.

Do not enable `full_access` or additional capabilities as a first
troubleshooting step. This app does not require them. Multiple mDNS stacks
can conflict on heavily customized systems; if Avahi cannot start, the app
reports the error in its log and exits cleanly.
