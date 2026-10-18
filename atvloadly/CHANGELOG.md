# Changelog

## 0.7.2-1

<!-- Release notes generated using configuration in .github/release.yml at 316de5e66b2ed27e1d8f7ce09a96789887eeafa9 -->

## What's Changed
### ⬆️ Dependency updates
* ⬆️ Update atvloadly release to v0.7.2 by @renovate[bot] in https://github.com/robinerhardt/home-assistant-atvloadly-app/pull/10


**Full Changelog**: https://github.com/robinerhardt/home-assistant-atvloadly-app/compare/v0.7.1-1...v0.7.2-1

## 0.7.1-1

<!-- Release notes generated using configuration in .github/release.yml at c303d2dd4a0216f8e42a4e055ce5033df2ef4300 -->

## What's Changed
### ⬆️ Dependency updates
* ⬆️ Update atvloadly release to v0.7.1 by @renovate[bot] in https://github.com/robinerhardt/home-assistant-atvloadly-app/pull/9


**Full Changelog**: https://github.com/robinerhardt/home-assistant-atvloadly-app/compare/v0.6.4-1...v0.7.1-1

## 0.6.4-1

<!-- Release notes generated using configuration in .github/release.yml at 97bf6a3bb83f9a528de13ec1703cda3ac89f3440 -->

## What's Changed
### ⬆️ Dependency updates
* ⬆️ Update atvloadly release to v0.6.4 by @renovate[bot] in https://github.com/robinerhardt/home-assistant-atvloadly-app/pull/8


**Full Changelog**: https://github.com/robinerhardt/home-assistant-atvloadly-app/compare/v0.6.3-1...v0.6.4-1

## 0.6.3-1

<!-- Release notes generated using configuration in .github/release.yml at 3dd5032759476bbd08c11c005cae08142c2c71b9 -->

## What's Changed
### ⬆️ Dependency updates
* ⬆️ Update atvloadly release to v0.6.3 by @renovate[bot] in https://github.com/robinerhardt/home-assistant-atvloadly-app/pull/7


**Full Changelog**: https://github.com/robinerhardt/home-assistant-atvloadly-app/compare/v0.6.2-1...v0.6.3-1

## 0.6.2-1

### Dependency updates

- Update atvloadly release to v0.6.2.

## 0.6.1-1

### Dependency updates

- Update atvloadly release to v0.6.1.

## 0.6.0-1

### Dependency updates

- Update actions/checkout action to v7.
- Update atvloadly release to v0.6.0.

## 0.4.10-1

- Update the pinned atvloadly image to v0.4.10.
- Add Renovate configuration to keep the image tag, digest, and Home Assistant
  app version synchronized in future update pull requests. New upstream
  releases start at wrapper revision `-1`.

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
