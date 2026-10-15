# Game servers

Game servers managed with [Pelican](https://pelican.dev/) (Panel and Wings) on two Ubuntu VMs in the DMZ.

**Status:** Running. Minecraft is open to players on the internet.

## Design

| Part | Choice | Why |
| --- | --- | --- |
| Panel | Web UI on its own VM (nginx, PHP, SQLite) | Kept apart from the game workloads |
| Wings | Daemon on its own VM, runs each server in Docker | Isolates game servers and gives them dedicated RAM (no ballooning or KSM) |
| Network | DMZ | No access to any internal network |
| Names | Own domain, resolved only by UniFi local DNS | No public DNS records for internal hosts |
| TLS | Let's Encrypt with DNS-01 through Cloudflare | Valid certificates without opening any inbound port. The API token can only edit DNS in one zone |
| Admin | SSH with keys only | No password login |


## Internet exposure

- Only the Minecraft port is forwarded from the WAN, to the Wings VM in the DMZ.
- Region blocking on the gateway allows inbound traffic from Norway only.
- Intrusion Prevention on the gateway inspects and blocks malicious traffic.
- A compromised game server stays in the DMZ, with no route to internal networks.

## Backup

| What | How |
| --- | --- |
| Game servers | Pelican backups every 2 hours, last 12 kept |
| VMs | Nightly Proxmox backup to the NAS (being set up) |

## Planned

- Test a full restore from backup.
