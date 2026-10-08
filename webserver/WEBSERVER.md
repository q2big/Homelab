# Webserver

Static websites on a Docker Compose VM in the DMZ. Not yet started

## Planned design

- One VM on the Proxmox host, in the DMZ network. It has no access to any internal network.
- `cloudflared` opens an outbound tunnel to Cloudflare, so no ports are open inbound and there is no port forwarding.
- The web server is only reachable from `cloudflared` on the internal Compose network.
- SSH admin access only from Trusted.

## Backup

| What | How |
| --- | --- |
| VM | Proxmox backup to the NAS |
| Website content and Compose files | Git |
