# Changelog

All notable changes to this repository are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Planned

- Add documentation as new homelab services are deployed and verified.

## [0.1.0] - 2026-08-02

### Added

- Initial public-safe Proxmox homelab documentation.
- ZFS mirror layout, capacity checks, and 8 GiB ARC limit.
- Samba unprivileged LXC setup, share configuration, and permission guidance.
- Jellyfin unprivileged LXC setup with AMD VA-API hardware acceleration.
- Network placeholders, startup ordering, backup procedures, and health checks.
- Sanitized LXC and Samba configuration examples.
- Troubleshooting notes for LXC networking, Samba permissions, Jellyfin
  hardware acceleration, HDR playback, and ZFS ARC usage.
- Local inventory template and pre-publication audit script.

### Security

- Replaced environment-specific addresses, guest IDs, UID/GID mappings, bridge
  names, and detailed hardware identifiers with placeholders.
- Added repository exclusions and a public-release safety checklist.

[Unreleased]: https://github.com/OWNER/REPOSITORY/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/OWNER/REPOSITORY/releases/tag/v0.1.0
