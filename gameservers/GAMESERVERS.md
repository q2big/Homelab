# Game servers

Game servers managed with [Pelican](https://pelican.dev/) (Panel and Wings) on two Ubuntu VMs in the DMZ.

**Status:** Running internally. Not exposed to the internet yet.

## Design

| Part | Choice | Why |
| --- | --- | --- |
| Panel | Web UI on its own VM (nginx, PHP, SQLite) | Kept apart from the game workloads |
| Wings | Daemon on its own VM, runs each server in Docker | Isolates game servers and gives them dedicated RAM (no ballooning or KSM) |
| Network | DMZ | No access to any internal network |
| Access | Panel, Wings and SSH only from Trusted | Nothing is reachable from the internet |
| Names | Own domain, resolved only by UniFi local DNS | No public DNS records for internal hosts |
| TLS | Let's Encrypt with DNS-01 through Cloudflare | Valid certificates without opening any inbound port. The API token can only edit DNS in one zone |
| Admin | SSH with keys only | No password login |

## Minecraft

- Paper server with an imported existing world.
- Whitelist and online mode on, so only approved accounts can join.

## Backup

| What | How |
| --- | --- |
| Game servers | Pelican backups every 2 hours, last 12 kept |
| VMs | Nightly Proxmox backup to the NAS (being set up) |

## Planned

- Expose the game port to the internet.
- Test a full restore from backup.
