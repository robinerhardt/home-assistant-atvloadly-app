# atvloadly

A Home Assistant OS wrapper for the pinned atvloadly release with a private
D-Bus, a query-only Avahi/mDNS service, and persistent storage under `/data`.
The editable `config.yaml` is exposed separately through the app-specific
`addon_configs` directory; credentials and runtime data remain private.

The app supports `aarch64` for Raspberry Pi systems running 64-bit Home
Assistant OS, as well as `amd64`. Upstream does not provide `armv7` builds.

The web UI listens on TCP port 5533. It does not include Home Assistant
authentication and must only be reachable from a trusted LAN. Do not configure
an internet-facing port forward.

See `DOCS.md` and the repository-level `README.md` for installation,
permissions, security, and troubleshooting details.
