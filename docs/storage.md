# Storage and ZFS

## Pool

The pool is a two-disk ZFS mirror:

```bash
zpool status data
zfs list
```

Expected mount point: `/data`.

Always identify physical disks through `/dev/disk/by-id/`, never transient
names such as `/dev/sdb`.

## Directory creation

These are regular folders, not child datasets:

```bash
mkdir -p /data/jellyfin/movies
mkdir -p /data/jellyfin/shows
```

Check whether child datasets accidentally exist:

```bash
zfs list -r data
```

Only `data` should be listed for the chosen design.

## ARC memory limit

The host has 32 GB RAM and also runs application workloads, so ZFS ARC is
capped at 8 GiB.

`/etc/modprobe.d/zfs.conf`:

```text
options zfs zfs_arc_max=8589934592
```

Apply persistently:

```bash
update-initramfs -u
```

Apply to the currently running kernel without rebooting:

```bash
echo 8589934592 > /sys/module/zfs/parameters/zfs_arc_max
```

Verify:

```bash
cat /sys/module/zfs/parameters/zfs_arc_max
arc_summary | grep -E 'Max target size|Current size'
free -h
```

ARC is reclaimable cache. Before the cap was applied, ARC reached about 26 GiB
during the initial media transfer; this was memory cache, not disk usage.

## Capacity checks

```bash
zpool list data
zpool status data
zfs list data
pvesm status
df -h /
```

The ZFS mirror provides redundancy against one disk failure. It is not a backup
against deletion, corruption, theft, or failure of both disks.
