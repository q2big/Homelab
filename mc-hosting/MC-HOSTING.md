# Minecraft server (Proxmox VM)

Reproducible Minecraft (Java) server in the DMZ. Everything runs from the Proxmox host
(web UI `:8006` > Shell). The VM is disposable. World data lives on the Proxmox host.

## Overview

```
Proxmox host
 |- /var/lib/vz/mcworlds/<profile>   <- world, mods, config (persistent)
 |- /var/lib/vz/mcsnaps/<profile>    <- snapshots every 30 min (2 days)
 `- VM (disposable)
     `- /srv/mcdata  (virtiofs mount of mcworlds)  -> container /data
NAS (share "proxmox")
 `- mcworlds-backup/                  <- nightly .tar.gz per profile (14 days)
```

## Files

| File | Purpose |
|---|---|
| `prepare-host.sh` | Run once. Enables snippets on `local`, downloads the Debian cloud image |
| `cloud-init.yaml` | VM definition: user, packages, `.env` (profile), `docker-compose.yml`, mount, firewall (ufw) |
| `create-vm.sh` | Creates VM, shares the world directory, applies cloud-init, starts the VM |
| `mc-snap.sh` | `take`, `list <profile>`, `restore <profile> <timestamp>` |
| `mc-nas.sh` | Nightly archive of the newest snapshot per profile to the NAS |


## Setup

```bash
cd /root/scripts/minecraft
./prepare-host.sh                       # once: image + snippets
nano cloud-init.yaml                    # user, password hash, whitelist name, profile in .env
python3 -c "import yaml; yaml.safe_load(open('cloud-init.yaml')); print('YAML OK')"
bash create-vm.sh
```

After 3-5 minutes (cloud-init installs Docker and pulls the image):

```bash
qm guest exec 220 -- cloud-init status
qm guest exec 220 -- docker ps
qm guest exec 220 -- docker logs --tail 20 minecraft     # ends with: Done (...)!
ls -la /var/lib/vz/mcworlds/vanilla/                     # server files appear here
```

Backups (cron on the host):

```bash
cat > /etc/cron.d/minecraft-backup <<'EOF'
*/30 * * * * root flock -n /run/mc-snap.lock /root/scripts/minecraft/mc-snap.sh take
45 3 * * * root /root/scripts/minecraft/mc-nas.sh
EOF
```

Run `mc-nas.sh` shortly after the Proxmox backup job so both follow the same rhythm.

## Profiles

The profile is the `.env` block inside `cloud-init.yaml`. Enable one block, comment out the other.

| Variable | vanilla | modded |
|---|---|---|
| `MC_PROFILE` | `vanilla` | `modded` |
| `MC_IMAGE` | `latest` | `java21` (match the pack's Java version) |
| `MC_TYPE` | `PAPER` | `AUTO_CURSEFORGE` |
| `MC_VERSION` | `LATEST` (or pin, e.g. `1.21.x`) | empty (the pack decides) |
| `MC_MEMORY` / `MC_MEM_LIMIT` | `3G` / `4g` | `6G` / `7g` (raise VM RAM in `create-vm.sh`) |
| `CF_PAGE_URL` / `CF_API_KEY` | empty | pack URL / key from console.curseforge.com |

Each profile has its own data directory, so switching never overwrites the other world.
The client must run the same Minecraft version (and, for modded, the same pack) as the server.

## Workflows

**Rebuild the VM** (worlds are untouched):

```bash
qm stop 220 && qm destroy 220 --purge && bash create-vm.sh
```

**Switch profile:** edit the `.env` block in `cloud-init.yaml`, then rebuild.
Quick change without rebuild (VM console): edit `/opt/minecraft/.env`, then
`cd /opt/minecraft && sudo docker-compose up -d`. Keep `cloud-init.yaml` in sync.

**Roll back after a death or mistake** (whole profile, all players):

```bash
cd /root/scripts/minecraft
./mc-snap.sh list vanilla                          # pick a time before the incident
./mc-snap.sh restore vanilla 2026-10-13-213000     # stops server, restores, starts server
```

**Disk lost, restore from the NAS archive:**

```bash
qm guest exec 220 -- docker stop minecraft
find /var/lib/vz/mcworlds/vanilla -mindepth 1 -delete
tar xzf /mnt/pve/nas-backup/mcworlds-backup/mc-vanilla-<date>.tar.gz -C /var/lib/vz/mcworlds/vanilla
qm guest exec 220 -- docker start minecraft
```

**Import or swap a world:** stop the container, put the world folder in
`/var/lib/vz/mcworlds/<profile>/world`, run `chown -R 1000:1000` on the profile directory, start the container.
Files can be dropped on the NAS share `proxmox` over SMB and copied from `/mnt/pve/nas-backup/`.


## Backups

| What | Where | When | Kept |
|---|---|---|---|
| Snapshots (hardlinked directories) | `/var/lib/vz/mcsnaps/<profile>/<timestamp>` | every 30 min | 96 (2 days) |
| Archives (`.tar.gz`) | NAS `mcworlds-backup/` | nightly 03:45 | 14 days |

Snapshots are taken with `save-off` / `save-all flush`, so the server keeps running and the data is consistent.
The Proxmox VM backup only covers the OS disk, not the worlds. Check usage with `du -sh /var/lib/vz/mcsnaps`.

## Open items

- Decide internet exposure (VPN/Tailscale, port forward, relay).
- Pin `MC_VERSION` once the preferred version is chosen.
- Test a full restore (snapshot and NAS archive) before relying on it.