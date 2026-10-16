# Jellyfin

Self-hosted media server for movies and TV shows. Jellyfin runs in Docker on a dedicated Ubuntu VM on the Proxmox host. The media library stays on the Synology NAS and is mounted read-only over NFS.

Only reachable from Trusted and VPN. Never exposed to the internet.


## Architecture

```
Trusted / VPN ──TCP 8096──▶ Media VLAN
                            └─ jellyfin VM
                               ├─ Docker: jellyfin/jellyfin (read-only media)
                               ├─ /opt/jellyfin/{config,cache}   local disk
                               └─ /mnt/jellyfin  ◀──NFSv4.1 ro, TCP 2049── NAS
```

## Security design

- **Own VLAN and zone.** Media VLAN is a separate firewall zone.
- **Media is read-only in three layers.** The NFS export is read-only, the host mount is `ro`, and the container gets `/media:ro`.
- **Least privilege on the NAS.** A dedicated DSM user `jellyfin` with no applications allowed and read access to the share only.
- **Hardened container.** Runs as UID, `cap_drop: ALL`, `no-new-privileges`, port bound to the VM address only.
- **Egress allowlist.** The VM can only reach the NAS (NFS), the gateway (DNS) and a short domain list.

## Setup

### Docker and Jellyfin

Docker Engine from Docker's own apt repository.

```bash
mkdir -p /opt/jellyfin/config /opt/jellyfin/cache
chown -R 1030:100 /opt/jellyfin/config /opt/jellyfin/cache
cp compose.yaml /opt/jellyfin/
cd /opt/jellyfin && docker compose up -d
```

## Operations

### Update Jellyfin

Read the release notes first, especially when the major version changes.

```bash
cd /opt/jellyfin
docker compose down
tar czf /root/jellyfin-config-$(date +%F).tar.gz -C /opt/jellyfin config
# change the image tag in compose.yaml
docker compose pull && docker compose up -d
```
