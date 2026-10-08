# Webserver

Last updated: October 2026

Static websites on a Docker Compose VM in the DMZ.

---

## 1. Overview

| Item | Value |
| --- | --- |
| Runtime | Docker Compose on one VM |
| Host | Proxmox host in the Lab VLAN (50) |
| Network | DMZ (VLAN 40) |
| Exposure | Cloudflare Tunnel (`cloudflared` connects out to Cloudflare). No port forwarding and no inbound ports open |

---

## 2. VM

| Item | Value |
| --- | --- |
| VM ID | TBD |
| Name | TBD |
| OS | TBD |
| RAM / vCPU | TBD |
| Disk | TBD |
| VLAN | 40 (DMZ) |
| IP (UniFi reservation) | TBD (`192.168.5.x`) |

---

## 3. Compose setup

TBD

---

## 4. Firewall

TBD

---

## 5. Hardening

TBD

---

## 6. Backup

| What | How |
| --- | --- |
| VM | Proxmox backup to the NAS |
| Website content and `compose.yaml` | Git |

---

## 7. Change log

| Date | Change |
| --- | --- |
| 2026-10 | Webserver VM planned to replace Kubernetes for the websites |
