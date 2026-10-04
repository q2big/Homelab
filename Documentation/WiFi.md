# Wi-Fi

Last updated: October 2026

Wi-Fi design for the U7 Pro XG. VLANs are in `vlan.md`, firewall policies in `Firewall.md`.

---

## 1. Goal

Everyone who connects to Wi-Fi gets minimal rights (internet only), except my own phone and laptop, which get Trusted access. This is done with one WPA3-Enterprise SSID where the login decides the VLAN.

---

## 2. Access point connection

| Setting | Value |
| --- | --- |
| Switch port | Native: Management (VLAN 1) |
| Tagged VLANs | WiFi (20), Trusted (10) |
| Power | PoE from the switch |

The AP itself stays on Management. Wi-Fi clients land in the VLAN assigned by the SSID or by RADIUS.

---

## 3. SSIDs

| SSID | Security | Network (VLAN) | Purpose |
| --- | --- | --- | --- |
| Main (Hovednett) | WPA3-Enterprise (RADIUS) | Per-user VLAN: Trusted (10) or WiFi (20) | Personal devices and everyone else |

Common settings: IPv6 off.

---

## 4. RADIUS (built-in UniFi RADIUS)

- Authentication: Local Credentials (users stored in UniFi).
- RADIUS Assigned VLAN Support.
- RADIUS profile is attached to the Main SSID.

### 4.1 Users

| User | VLAN | Used by | Result |
| --- | --- | --- | --- |
| User 1 | 10 (Trusted) | My phone and laptop | Trusted rights |
| User 2 | 20 (WiFi) | Everyone else | Internet only |

Each user has these attributes:

| Attribute | Value |
| --- | --- |
| Tunnel Type | 13 (VLAN) |
| Tunnel Medium Type | 6 (802) |
| VLAN ID | 10 or 20 |

### 4.2 Credentials

The two profiles have a different strong password and username. 

---

## 5. How enforcement works

1. A device connects to Main and logs in as User 1 or User 2.
2. RADIUS returns the VLAN (10 or 20).
3. The AP places the client on that VLAN. The client gets an address from that network's DHCP.
4. The firewall zone for that network decides what the client can reach (see `Firewall.md`).

---

## 7. Pending

- Create the Guest and IoT SSIDs
- Maybes: certificate-based authentication per device instead of shared users

---

## 8. Change log

| Date | Change |
| --- | --- |
| 2026-10 | WPA3-Enterprise with built-in RADIUS and two users (VLAN 10 and 20) |