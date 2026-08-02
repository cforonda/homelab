# Proxmox Homelab

Public-safe configuration and operating notes for a Proxmox homelab providing
ZFS-backed file storage, Samba access, and Jellyfin with AMD VA-API
transcoding.

This repository is intentionally an anonymized template. Values such as
`SAMBA_IP`, `SAMBA_CTID`, and `RENDER_GID` must be replaced locally. Keep the
real inventory in an ignored file rather than committing it.

## Hardware

| Component | Specification |
| --- | --- |
| Platform | AMD Ryzen system with integrated graphics |
| Memory | 32 GB class |
| Proxmox disk | Dedicated NVMe system disk |
| Data disks | Two NAS HDDs in a ZFS mirror |
| Hypervisor | Proxmox VE 9.x |

## Current services

| ID | Name | Type | Address | Purpose | State |
| --- | --- | --- | --- | --- | --- |
| SAMBA_CTID | `samba` | Unprivileged Debian LXC | `SAMBA_IP/LAN_PREFIX` | Windows file access | Deployed |
| JELLYFIN_CTID | `jellyfin` | Unprivileged Debian LXC | `JELLYFIN_IP/LAN_PREFIX` | Media streaming | Deployed |

Gateway: `GATEWAY_IP`. Bridge: `BRIDGE_NAME`.

## Local placeholder values

Copy [`inventory.example.env`](inventory.example.env) to `inventory.private.env`
and fill it out locally. The private copy is ignored by Git.

## Storage layout

The two data disks form one ZFS mirror named `data`. There are no child ZFS
datasets. Directories such as `jellyfin` are ordinary folders within the root
dataset.

```text
/data/
└── jellyfin/
    ├── movies/
    └── shows/
```

Jellyfin reads `/data/jellyfin` directly through an LXC bind mount. It does not
read media through Samba.

## Documentation

- [Changelog](CHANGELOG.md)
- [Architecture](docs/architecture.md)
- [Storage and ZFS](docs/storage.md)
- [Samba](docs/samba.md)
- [Jellyfin](docs/jellyfin.md)
- [Networking](docs/networking.md)
- [Operations and backups](docs/operations.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Public-repository checklist](docs/publication-checklist.md)
- [Security policy](SECURITY.md)

## Repository safety

The example configurations are sanitized. Never commit private keys, passwords,
Jellyfin API keys, cookies, `.env` files with real values, or live application
databases.
