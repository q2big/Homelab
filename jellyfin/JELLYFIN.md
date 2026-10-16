# Jellyfin

Self-hosted media server for movies and TV shows. Jellyfin runs in Docker on a dedicated Ubuntu VM on the Proxmox host, behind Traefik for HTTPS. The media library stays on the Synology NAS and is mounted read-only over NFS.

Only reachable from Trusted and VPN. Never exposed to the internet.

## Architecture

```
Trusted / VPN ──TCP 443──▶ Media VLAN
                           └─ jellyfin VM
                              ├─ Docker: traefik (TLS) ──▶ jellyfin (read-only media)
                              ├─ /opt/jellyfin/{config,cache}   local disk
                              └─ /mnt/jellyfin  ◀──NFSv4.1 ro, TCP 2049── NAS
```

## Security design

- **Own VLAN and zone.** Media VLAN is a separate firewall zone.
- **Media is read-only in three layers.** The NFS export is read-only, the host mount is `ro`, and the container gets `/media:ro`.
- **Least privilege on the NAS.** A dedicated DSM user `jellyfin` with no applications allowed and read access to the share only.
- **Hardened containers.** Non-root, `cap_drop: ALL`, `no-new-privileges`. Traefik has no Docker socket.
- **HTTPS.** Let's Encrypt certificate through the DNS challenge, so no inbound ports from the internet. The hostname only exists in local DNS.

## Setup

Docker Engine from Docker's own apt repository.

```bash
mkdir -p /opt/jellyfin/config /opt/jellyfin/cache /opt/jellyfin/traefik/acme
chown -R <jellyfin-uid>:<gid> /opt/jellyfin/config /opt/jellyfin/cache
chown <traefik-uid>:<traefik-uid> /opt/jellyfin/traefik/acme && chmod 700 /opt/jellyfin/traefik/acme
cp compose.yaml .env.example /opt/jellyfin/ && cp traefik/dynamic.yaml /opt/jellyfin/traefik/
cd /opt/jellyfin && cp .env.example .env && chmod 600 .env   # fill in .env
docker compose up -d
```

In Jellyfin: set LAN networks to the Trusted and VPN subnets, add Traefik as a known proxy, and turn remote connections off.

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

### Certificate

Renewed automatically by Traefik. If HTTPS fails, check `docker compose logs traefik | grep -i acme`.