# Jellyfin — CT JELLYFIN_CTID

## Container configuration

| Setting | Value |
| --- | --- |
| VMID | JELLYFIN_CTID |
| Hostname | `jellyfin` |
| OS | Debian 12 |
| CPU / RAM | 2 cores / 4 GB |
| Root disk | 16 GB on `local-lvm` |
| Type | Unprivileged LXC |
| Address | `JELLYFIN_IP/LAN_PREFIX` |
| Gateway | `GATEWAY_IP` |
| Media mount | `/data/jellyfin` → `/mnt/jellyfin`, read-only |
| GPU device | `/dev/dri/renderD128` mapped as group RENDER_GID, mode 0660 |

## Host configuration

```bash
pct set JELLYFIN_CTID -mp0 /data/jellyfin,mp=/mnt/jellyfin,ro=1
pct set JELLYFIN_CTID -features nesting=1
pct set JELLYFIN_CTID -dev0 /dev/dri/renderD128,gid=RENDER_GID,mode=0660
pct set JELLYFIN_CTID -onboot 1 -startup order=2,up=20,down=30
```

`gid=RENDER_GID` matches the `render` group inside CT JELLYFIN_CTID. Confirm rather than assuming
the value on a rebuilt container:

```bash
pct exec JELLYFIN_CTID -- getent group render
pct exec JELLYFIN_CTID -- ls -ln /dev/dri
```

## Libraries

| Jellyfin library | Content type | Container path |
| --- | --- | --- |
| Movies | Movies | `/mnt/jellyfin/movies` |
| Shows | TV Shows | `/mnt/jellyfin/shows` |

The server was configured as a clean Jellyfin installation. Users and watch
history from the former server were intentionally not migrated. Media files,
posters, and metadata can be rescanned or managed by Jellyfin on the new server.

## Hardware acceleration

Configure Dashboard → Playback:

- Hardware acceleration: **VA-API**
- Device: `/dev/dri/renderD128`
- Enable decoding for: H.264, HEVC, HEVC 10-bit, VP9, VP9 10-bit, and AV1
- Enable hardware encoding
- Do not enable AV1 encoding; the iGPU reports AV1 decode but not encode
- Leave server-side HDR tone mapping disabled on this host for now

Verified capabilities:

- Decode: H.264, HEVC, HEVC Main 10, VP9, VP9 Profile 2, AV1, JPEG
- Encode: H.264 and HEVC
- Video processing: supported

Verify VA-API as the Jellyfin service account:

```bash
pct exec JELLYFIN_CTID -- runuser -u jellyfin -- \
  /usr/lib/jellyfin-ffmpeg/vainfo \
  --display drm \
  --device /dev/dri/renderD128
```

The driver should report `radeonsi` and return `va_openDriver() returns 0`.

## HDR playback guidance

For the HDR-capable LG TV, prefer **Original** quality and direct play for 4K
HEVC HDR content. Server-side tone mapping previously failed because FFmpeg
could not find an OpenCL platform. Vulkan device discovery worked, but disabling
tone mapping produced the reliable configuration.

Image-based subtitles such as DVDSUB/PGS can force video burn-in and therefore
transcoding. Select a text subtitle track such as SRT when available, or disable
subtitles when diagnosing a fatal player error.

## Playback verification

During playback, open the Jellyfin dashboard and inspect the session:

- **Direct Play:** preferred for compatible 4K HDR clients
- **Direct Stream:** container/audio repack without video encoding
- **Transcoding:** confirm VA-API is shown and host CPU remains relatively low

Host-side checks:

```bash
pct exec JELLYFIN_CTID -- systemctl status jellyfin --no-pager
pct exec JELLYFIN_CTID -- journalctl -u jellyfin -n 100 --no-pager
```
