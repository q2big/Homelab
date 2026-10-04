# Firewall

Last updated: October 2026

Firewall design for the UCG-Fiber using UniFi Zone-Based Firewall (ZBF). VLANs and subnets are in `vlan.md`, Wi-Fi in `WiFi.md`.

---

## 1. Principles

- **Default deny between zones.** Custom zones block traffic to all other zones until a policy allows it.
- **Least privilege.** Each zone gets only the access it needs.
- **Private ranges are not reachable from untrusted zones** via the External path.

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
| Black | Custom | Black | Blocked from everything |

---

## 3. Intended access model

| From \ To | Gateway | External (internet) | Trusted | WiFi | DMZ | Management | Black |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Trusted | Limited (DHCP, DNS, NTP) | Allow | - | Block | Block | Block | Block |
| WiFi | Limited (DHCP, DNS, NTP) | Allow (filtered) | Block | - | Block | Block | Block |
| Guest / Hotspot | Limited (DHCP, DNS) | Allow (filtered) | Block | Block | Block | Block | Block |
| DMZ | Limited (DHCP, DNS) | Allow (filtered) | Block | Block | - | Block | Block |
| Management | Allow | Allow (updates) | Block | Block | Block | - | Block |
| Black | Block | Block | Block | Block | Block | Block | - |

Management reaches other zones only through explicit policies when required. Inbound access from the internet is allowed only to the DMZ through port forwards.

---

## 4. Policies

### 4.1 WiFi zone (implemented)

| Policy | Source | Destination | Action |
| --- | --- | --- | --- |
| Allow DHCP | WiFi | Gateway (UDP 67/68) | Allow |
| Allow DNS | WiFi | Gateway (TCP/UDP 53) | Allow |
| Allow NTP | WiFi | Gateway (UDP 123) | Allow |
| Block gateway | WiFi | Gateway (everything else) | Block |
| Allow internet | WiFi | External | Allow |


### 4.2 Trusted zone (partly implemented)

| Policy | Source | Destination | Action | Status |
| --- | --- | --- | --- | --- |
| Allow internet | Trusted | External | Allow | Done |
| Allow gateway services (DHCP, DNS, NTP) | Trusted | Gateway | Allow | Done |
| Allow UniFi admin access | Trusted | Gateway (192.168.1.1) | Allow while required | Done |
| Restrict gateway access | Trusted | Gateway (everything else) | Block | Pending |

### 4.3 Black zone

| Policy | Source | Destination | Action | Status |
| --- | --- | --- | --- | --- |
| Block gateway | Black | Gateway | Block | Pending |
| Block internet | Black | External | Block | Pending |

Black also has DHCP off and no gateway, so devices on unused ports get nothing.

---

## 5. Pending

- Complete Trusted and Black policies (4.2, 4.3)
- Move Guest to Hotspot or create a custom zone.
- Policies for Servers (30) and IoT (50) when created
- VPN zone policies for WireGuard
- IoT zone: internet only, no access to other zones, mDNS/casting rules as needed

---

## 6. Change log

| Date | Change |
| --- | --- |
| 2026-10 | Upgraded to Zone-Based Firewall. Custom zones for Trusted, WiFi, DMZ and Black. WiFi policies implemented |