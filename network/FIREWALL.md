# Firewall

Zone-based firewall (UniFi ZBF) on the UCG-Fiber.

## Principles

- **Default deny between zones.** Custom zones block traffic to all other zones until a policy allows it.
- **Least privilege.** Each zone gets only the specific services it needs.
- **No inbound port forwarding** to internal networks. Remote access goes through VPN.
- **Domain-filtered egress** for servers, so they can reach only the services they need (updates, time).

## Zones

| Zone | Networks | Purpose |
| --- | --- | --- |
| Internal | Management | Network gear |
| Trusted | Trusted | Personal devices, admin access |
| WiFi | WiFi | Internet only |
| Servers | Servers | NAS |
| DMZ | DMZ | Internet-exposed websites |
| Lab | Lab | Proxmox host |
| VPN | OpenVPN | Remote access to the NAS |
| Black | Black | Blocked from everything |
| Hotspot | - | Isolated, internet only. Planned home of Guest |

## Access model

| From \ To | Internal | External | Gateway | VPN | DMZ | Trusted | WiFi | Servers | Lab |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Internal | - | Allow | Allow | Allow | Block | Block | Block | Limited | Block |
| Trusted | Block | Allow | Limited | Block | Limited | - | Block | Limited | Limited |
| WiFi | Block | Filtered | Limited | Block | Block | Block | - | Block | Block |
| VPN | Block | Allow | Limited | Block | Block | Block | Block | Limited | Block |
| Servers | Limited | Limited | Limited | Block | Block | Limited | Block | - | Block |
| DMZ | Block | Filtered | Limited | Block | - | Block | Block | Block | Block |
| Lab | Block | Limited | Limited | Block | Block | Block | Block | Limited | - |
| Black | Block | Block | Block | Block | Block | Block | Block | Block | Block |

- **Allow:** all traffic permitted.
- **Filtered:** internet allowed, with restrictions such as blocked DNS bypass and private ranges.
- **Limited:** only specific services, everything else blocked.
- **Block:** no traffic. Reply traffic for c
onnections started from the other side is always allowed.
Highlights:

- The DMZ cannot reach any internal network, so a compromised website cannot reach the NAS or personal devices.
- VPN clients reach only file sharing on the NAS, and cannot reach each other.
- Admin access to the Proxmox host and the DMZ is only possible from Trusted.
