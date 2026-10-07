# Firewall

Last updated: October 2026

Firewall design for the UCG-Fiber using UniFi Zone-Based Firewall (ZBF).

---

## 1. Principles

- **Default deny between zones.** Custom zones block traffic to all other zones until a policy allows it.
- **Least privilege.** Each zone gets only the access it needs.

---

## 2. Zones

| Zone | Type | Networks | Notes |
| --- | --- | --- | --- |
| Internal | Built-in | Management, Guest | Guest is planned to move to Hotspot (Not yet decided) |
| External | Built-in | Internet | WAN |
| Gateway | Built-in | - | The UCG-Fiber itself |
| VPN | Built-in | OpenVPN | Remote access clients |
| Hotspot | Built-in | - | Isolated from other zones, internet only. Planned home of Guest |
| DMZ | Built-in | - | DMZ |
| Trusted | Custom | Trusted | |
| WiFi | Custom | WiFi | |
| Servers | Custom | Servers | NAS |
| Black | Custom | Black | Blocked from everything |
| Lab | Custom | Lab | Proxmox host |

---

## 3. Intended access model

| From \ To | Internal | External | Gateway | VPN | Hotspot | DMZ | Trusted | Black | WiFi | Servers | Lab |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Internal| - | Allow | Allow | Allow | Block | Block | Block | Block | Block | Limited | Block |
| External | Return only | - | Limited | Return only | Return only | Return only | Return only | Return only | Return only | Return only | Return only |
| Gateway | Allow | Allow | - | Allow | Allow | Allow | Allow | Allow | Allow | Allow | Allow |
| VPN | Block | Allow | Limited | Block | Block | Block | Block | Block | Block | Limited | Block |
| Hotspot | Return only | Allow (filtered) | Limited | Return only | - | Block | Block | Block | Block | Block | Block |
| DMZ | Return only | Allow (filtered) | Limited | Return only | Block | - | Block | Block | Block | Block | Block |
| Trusted | Block | Allow | Limited | Block | Block | Block | - | Block | Block | Limited | Limited |
| Black | Block | Block | Block | Block | Block | Block | Block | - | Block | Block | Block |
| WiFi | Block | Allow (filtered) | Limited | Block | Block | Block | Block | Block | - | Block | Block |
| Servers | Limited | Limited | Limited | Block | Block | Block | Limited | Block | Block | - | Block |
| Lab | Block | Limited | Limited | Block | Block | Block | Block | Block | Block | Limited | - |

- Allow: All traffic from the source zone to the destination zone is permitted.
- Allow (filtered): Internet is allowed, but with restrictions such as blocked DNS bypass, blocked private ranges etc.
- Limited: Only the listed ports or services are allowed. Everything else is blocked.
- Block: No traffic is allowed.
- Return only: Only reply traffic for connections the destination zone started is allowed. Nothing can be started from this side.

---

## 4. Change log

| Date | Change |
| --- | --- |
| 2026-10 | Upgraded to Zone-Based Firewall. Custom zones for Trusted, WiFi, DMZ and Black. WiFi policies implemented |
| 2026-10 | Added Servers zone and NAS access policies |
| 2026-10 | Added Management and Trusted to Servers (TCP 5001, 445). NTP allowed to no.pool.ntp.org |
| 2026-10 | Added VPN zone policies for OpenVPN (SMB only) |
| 2026-10 | Added Lab zone (VLAN 50) for the Proxmox host |
