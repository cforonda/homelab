# Samba — CT SAMBA_CTID

## Container configuration

| Setting | Value |
| --- | --- |
| VMID | SAMBA_CTID |
| Hostname | `samba` |
| OS | Debian 12 |
| CPU / RAM | 1 core / 512 MB |
| Root disk | 4 GB on `local-lvm` |
| Type | Unprivileged LXC |
| Address | `SAMBA_IP/LAN_PREFIX` |
| Gateway | `GATEWAY_IP` |
| Bind mount | `/data` → `/mnt/data` |

The container uses nesting because Debian 12's systemd 252 otherwise produces
a Proxmox warning. Nesting should only be enabled where required.

## Host configuration

```bash
pct set SAMBA_CTID -mp0 /data,mp=/mnt/data
pct set SAMBA_CTID -features nesting=1
pct set SAMBA_CTID -onboot 1 -startup order=1,up=20,down=30
```

## Samba share

The active design exposes one share named `data`. See
[`configs/samba/smb.conf.example`](../configs/samba/smb.conf.example).

Validate and restart after changes:

```bash
pct exec SAMBA_CTID -- testparm -s
pct exec SAMBA_CTID -- systemctl restart smbd
pct exec SAMBA_CTID -- systemctl status smbd --no-pager
```

Windows path:

```text
\\SAMBA_IP\data
```

## Unprivileged ownership

Unprivileged LXC user IDs are translated to host IDs. Determine the mapped host
UID for the dedicated Samba account rather than publishing or hard-coding it.
The placeholder below represents that mapped value:

```bash
chown -R HOST_MAPPED_UID:HOST_MAPPED_UID /data/jellyfin
```

Use a dedicated non-root Samba account and a shared host group. Do not apply a
recursive ownership change to `/data` without first reviewing every service
that uses it.

## Useful checks

```bash
pct exec SAMBA_CTID -- pdbedit -L
pct exec SAMBA_CTID -- testparm -s
pct exec SAMBA_CTID -- ls -ldn /mnt/data /mnt/data/jellyfin
pct exec SAMBA_CTID -- systemctl is-system-running
```
