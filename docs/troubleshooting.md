# Troubleshooting

## Container reports `degraded`

Identify failed units:

```bash
pct exec <vmid> -- systemctl is-system-running
pct exec <vmid> -- systemctl --failed --no-pager
pct exec <vmid> -- systemctl status networking.service --no-pager -l
pct exec <vmid> -- journalctl -u networking.service -b --no-pager -n 100
```

### IPv6 DHCP timeout

Symptoms include repeated `Solicit on eth0` messages followed by a networking
service timeout. If IPv6 is not intentionally used, set the Proxmox network
configuration to `ip6=manual`, then restart the container.

### Stale failed state

After fixing the cause:

```bash
pct exec <vmid> -- systemctl reset-failed
pct exec <vmid> -- systemctl is-system-running
```

## Samba is reachable but cannot write

```bash
ls -ldn /data /data/jellyfin /data/jellyfin/movies /data/jellyfin/shows
pct exec SAMBA_CTID -- id
pct exec SAMBA_CTID -- pdbedit -L
pct exec SAMBA_CTID -- testparm -s
pct exec SAMBA_CTID -- ls -ldn /mnt/data/jellyfin
```

Replace `HOST_MAPPED_UID` with the verified host-side mapping for the dedicated
Samba account. Avoid broad `chmod 777` workarounds.

Windows may cache old SMB credentials. Remove and reconnect the mapped drive if
permissions appear unchanged after a server-side correction.

## Jellyfin cannot see media

```bash
pct config JELLYFIN_CTID
pct exec JELLYFIN_CTID -- ls -la /mnt/jellyfin
pct exec JELLYFIN_CTID -- find /mnt/jellyfin -maxdepth 2 -type d
```

Confirm the mount uses `mp=/mnt/jellyfin` with a leading slash. The earlier
`mp=mnt/jellyfin` form was corrected.

## Jellyfin hardware acceleration failure

```bash
pct exec JELLYFIN_CTID -- ls -ln /dev/dri
pct exec JELLYFIN_CTID -- id jellyfin
pct exec JELLYFIN_CTID -- getent group render
pct exec JELLYFIN_CTID -- runuser -u jellyfin -- \
  /usr/lib/jellyfin-ffmpeg/vainfo --display drm \
  --device /dev/dri/renderD128
```

Expected device: major 226, minor 128, group RENDER_GID inside CT JELLYFIN_CTID, mode 0660.

For a 4K HEVC HDR fatal player error, first test Original quality without
image-based subtitles. Confirm whether the session says Direct Play or
Transcoding. Keep server tone mapping disabled unless a later driver/Jellyfin
update is tested successfully.