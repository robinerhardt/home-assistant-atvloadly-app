# Changelog

## 0.4.8-2

- Generate and persist a valid D-Bus machine ID when the upstream image ships
  with an empty `/etc/machine-id`.
- Expose the editable atvloadly `config.yaml` through the app-specific
  `addon_configs` directory while keeping credentials and runtime data private.

## 0.4.8-1

- Wrap atvloadly v0.4.8 for Home Assistant OS.
- Add a private D-Bus and browse-only Avahi service for Apple TV discovery.
- Support `aarch64` and `amd64`; reject unsupported `armv7` installations.
- Use host networking without full hardware access or extra capabilities.
- Disable the unauthenticated upstream web-terminal process launcher.
