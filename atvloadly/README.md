# atvloadly

A Home Assistant OS wrapper for atvloadly v0.4.8 with a private D-Bus, a
query-only Avahi/mDNS service, and persistent storage under `/data`.

The app supports `aarch64` for Raspberry Pi systems running 64-bit Home
Assistant OS, as well as `amd64`. Upstream does not provide `armv7` builds.

The web UI listens on TCP port 5533. It does not include Home Assistant
authentication and must only be reachable from a trusted LAN. Do not configure
an internet-facing port forward.

See `DOCS.md` and the repository-level `README.md` for installation,
permissions, security, and troubleshooting details.
