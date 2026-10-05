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
| VPN | Built-in | - | Reserved for WireGuard clients |
| Hotspot | Built-in | - | Isolated from other zones, internet only. Planned home of Guest |
| DMZ | Built-in | - | DMZ |
| Trusted | Custom | Trusted | |
| WiFi | Custom | WiFi | |
| Servers | Custom | Servers | NAS, AI server |
| Black | Custom | Black | Blocked from everything |

---

## 3. Intended access model

| From \ To | Gateway | External (internet) | Trusted | WiFi | Servers | DMZ | Management | Black |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Trusted | Limited | Allow | - | Block | Limited | Block | Block | Block |
| Servers | Limited | Limited | Block | Block | - | Block | Block | Block |
| WiFi | Limited | Allow (filtered) | Block | - | Block | Block | Block | Block |
| Guest / Hotspot | Limited | Allow (filtered) | Block | Block | Block | Block | Block | Block |
| DMZ | Limited | Allow (filtered) | Block | Block | Block | - | Block | Block |
| Management | Allow | Allow (updates) | Block | Block | Block | Block | - | Block |
| Black | Block | Block | Block | Block | Block | Block | Block | - |


Management reaches other zones only through explicit policies when required. Inbound access from the internet is allowed only to the DMZ through port forwards.


---

## 4. Pending

- Complete Trusted and Black policies (4.2, 4.3)
- Move Guest to Hotspot or create a custom zone.
- Policies for IoT (50) when created
- VPN zone policies for WireGuard
- IoT zone: internet only, no access to other zones, mDNS/casting rules as needed

---

## 5. Change log

| Date | Change |
| --- | --- |
| 2026-10 | Upgraded to Zone-Based Firewall. Custom zones for Trusted, WiFi, DMZ and Black. WiFi policies implemented |
| 2026-10 | Added Servers zone and NAS access policies |