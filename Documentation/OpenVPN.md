# OpenVPN

Last updated: October 2026

Remote access to the NAS through the OpenVPN server on the UCG-Fiber.

---

## 1. Overview

| Item | Value |
| --- | --- |
| Purpose | SMB access to the NAS (`192.168.7.10`) from outside the home network |
| Server | OpenVPN server on the UCG-Fiber |
| Zone | VPN |
| Client subnet | `192.168.8.0/24` (not a VLAN) |
| Allowed access | TCP 445 (SMB) to the NAS, DNS to the gateway, internet |

---

## 2. Server settings

| Setting | Value |
| --- | --- |
| Type | OpenVPN |
| Port | 1194 |
| Protocol | UDP |

---

## 3. Address

Clients reach home through the WAN IP configured in UniFi.

---

## 4. Users

One user per device, so a single device can be revoked without affecting the others.

---

## 10. Security notes

- The `.ovpn` file is sensitive. Delete it from the device after import.
- Right now all traffic goes through the VPN when its enabled, not only traffic to the NAS.
- VPN → VPN is blocked, so VPN clients cannot reach each other.
- No port forwarding to internal networks. Only UDP 1194 is open on the WAN.

---

## 11. Change log

| Date | Change |
| --- | --- |
| 2026-10 | OpenVPN server on the UCG-Fiber with user for Mac. SMB-only access to the NAS |
