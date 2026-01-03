# Changelog

All notable changes to **Pulsar** will be documented in this file.

This project follows:
- [Semantic Versioning](https://semver.org/) for releases
- An image-based delivery model (bootc / OSTree)

Changes are grouped by **image behavior**, not individual commits.

---

## [Unreleased]

### Added
- 

### Changed
- 

### Fixed
- 

### Removed
- 

---

## [0.1.0] – YYYY-MM-DD

### Added
- Initial Fedora COSMIC Atomic 43 base
- COSMIC desktop with Wayland-first configuration
- Homebrew integration (`ublue-os/brew`)
- Flatpak auto-install (system list)
- Papirus-Dark icon theme with violet folder accents
- Custom COSMIC defaults:
  - Accent color (`#8b5cf6`)
  - Default wallpaper (Runaway Black Hole)
- Plymouth splash theme (Pulsar)
- GitHub Actions build + release workflows
- Cosign-signed container images

### Changed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Removed
- N/A

---

## Release Notes

- Releases are published as **bootable container images** to `ghcr.io/iamtuaig/pulsar`
- Rollbacks are handled by `bootc`
- User configuration is only seeded on **first login**
- Existing user settings are never overwritten

---

## Upgrade Notes

### From earlier versions
- Use:
  ```bash
  sudo bootc switch ghcr.io/iamtuaig/pulsar:<version>
  sudo reboot