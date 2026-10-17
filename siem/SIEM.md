# Wazuh

Central log collection and threat detection for the homelab with Wazuh. It shows who logs in where, what changes on the servers, which known vulnerabilities they have, and what the gateway blocks. Wazuh (manager, indexer and dashboard) runs on a dedicated Ubuntu VM on the Proxmox host, installed with the official installation assistant.

Only reachable from Trusted. Never exposed to the internet.

## What it collects

- **Agents on the servers and the admin machine:** logins and sudo (SSH and the Proxmox web UI included), system logs, file integrity of system files, CIS configuration checks, known vulnerabilities in installed packages, and an inventory of packages, ports and processes.
- **The gateway:** UniFi security events (IPS, honeypot, firewall), admin logins and configuration changes, sent as CEF over syslog.

## Security design

- **Own VLAN and zone.** Log sources reach only the agent and syslog ports. The SIEM cannot reach any internal network, and its egress is limited to updates and threat feeds.
- **Agent enrollment needs a password.** Without it, anything that reaches port 1515 can register as an agent and send fake logs.
- **Syslog from the gateway only.** The listener is bound to the VM address and accepts only the gateway (`allowed-ips`).
- **Agents match the manager version.** Installed from a single package, not a permanent repository, so a normal upgrade never takes an agent past the manager.
- **Admin from Trusted only.** Dashboard over HTTPS, SSH with keys.



## UniFi decoders

Havent fixed this yet.

