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

- Only the game port is forwarded, to the Wings VM in the DMZ.
- Geo-IP filtering on the gateway limits where inbound traffic can come from.
- Intrusion Prevention on the gateway inspects and blocks malicious traffic.
- A compromised game server stays in the DMZ, with no route to internal networks.

## Backup

| What | How |
| --- | --- |
| Game servers | Pelican backups every 2 hours, last 12 kept |
