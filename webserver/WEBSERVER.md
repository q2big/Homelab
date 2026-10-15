# Webserver

Static websites on a Docker Compose VM in the DMZ, published through a Cloudflare Tunnel. Active.

## Design

- Ubuntu VM in the DMZ, created manually in Proxmox. No access to internal networks. SSH key-only, from Trusted.
- `cloudflared` opens an outbound tunnel to Cloudflare. 
- Sites are served by `nginx-unprivileged` containers on an internal Compose network with no internet access. Only `cloudflared` can reach them.
- All containers are read-only, drop all capabilities and run with `no-new-privileges`. Images are pinned.

| Container | Serves |
| --- | --- |
| `cloudflared` | Tunnel to Cloudflare |
| `web` | --- |
| `parked` | "Domain for sale" page for parked domains |

## Deploying content

- `web` content is going to live in a private GitHub repository.
- `parked` content is in this folder.

## Secrets

| Secret | Where |
| --- | --- |
| Tunnel token | `.env` on the VM (not in Git, see `.env.example`) |
