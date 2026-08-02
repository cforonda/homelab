# Security

## Never commit

- Samba or Linux passwords and password databases
- Jellyfin API keys, tokens, cookies, databases, or complete configuration
- SSH or TLS private keys
- Real internal addresses, hostnames, MAC addresses, VLANs, and device IDs
- Names, email addresses, domains, dynamic-DNS names, and physical locations
- Public IP addresses when they are not needed for documentation

Use `.env.example` files with placeholder values for documentation. Store real
secrets only on the target machine with restrictive permissions.

An internal RFC1918 address is not reachable from the public internet by
itself, but removing the real network inventory avoids unnecessary
fingerprinting and accidental correlation with other public information.

## Network exposure

- Keep Samba LAN-only and do not create a router port-forward for it.
- Jellyfin remote access should use a deliberate solution such as a VPN or a
  properly secured reverse proxy, not an undocumented open port.

## Container boundaries

Both deployed LXCs are unprivileged. Bind mounts expose only the required host
paths. Jellyfin receives `/data/jellyfin` read-only and receives only the AMD
render node, not the whole `/dev/dri` directory.

## Before publishing

Run `scripts/audit-public.sh` and review the complete staged diff with
`git diff --cached`. Automated checks cannot identify every personal detail or
determine whether a value was intentionally public.
