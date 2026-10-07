# VLANs & Topology

Last updated: October 2026

This document describes the VLAN layout, addressing, firewall zone membership, switch port assignments and physical topology of the home network.

---

## 1. Design principles

- **Segmentation by function.** Every use case has its own VLAN and subnet.
- **Management is isolated.** VLAN 1 carries only network gear and the admin port. No clients live there.
- **Black hole VLAN.** All unused switch ports are assigned to VLAN 99, which has no DHCP, no gateway access and no internet.
- **Internet-exposed services live in the DMZ** and have no route into any other internal network.
- **IPv6 is disabled** on all networks until it is planned and filtered.
- **DHCP Guarding** is enabled per network, trusting only that network's gateway address.

---

## 2. Logical view


```
                         Internet
                            |
                      [ UCG-Fiber ]
                            |
   +-----------+-----------+-----------+-----------+-----------+----------+
   |           |           |           |           |           |          |
Management   Trusted      WiFi        Guest       DMZ        Black      Servers
 VLAN 1      VLAN 10     VLAN 20     VLAN 90    VLAN 40     VLAN 99     VLAN 30
(net gear)   (wired      (Wi-Fi      (visitors) (exposed    (unused     (NAS)
             clients)    clients)               servers)     ports)

Planned: IoT (VLAN 50)
```

---

## 3. VLANs and subnets

| VLAN | Name | Subnet | Gateway | DHCP | Purpose | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Management | 192.168.1.0/24 | 192.168.1.1 | Server (small pool) | UCG-Fiber, switch, AP and the admin port only | Active |
| 10 | Trusted | 192.168.3.0/24 | 192.168.3.1 | Server (.100-.200) | Personal devices (wired, plus Wi-Fi users mapped by RADIUS) | Active |
| 20 | WiFi | 192.168.4.0/24 | 192.168.4.1 | Server | Wi-Fi clients with minimal rights (internet only) | Active |
| 30 | Servers | 192.168.7.0/24 | 192.168.7.1 | Server | NAS | Active |
| 40 | DMZ | 192.168.5.0/24 | 192.168.5.1 | Server | Internet-exposed game servers | Active VLAN, but planned project |
| 90 | Guest | 192.168.6.0/24 | 192.168.6.1 | Server | Visitors | Active VLAN, but planned project |
| 99 | Black | 192.168.2.0/24 | - | **None** | Black hole for unused ports | Active |
| 50 | IoT | to be assigned | - | Server | Smart home devices | Planned |

Notes:

- VLAN 1 is the UniFi *Default* network. Its VLAN ID cannot be changed or deleted, so it is used as the management network.
- Each network uses its own `192.168.x.0/24` subnet.
- Black (VLAN 99) has DHCP set to *None*, *Allow Internet Access* off, and no gateway access.
- Planned networks get the next free `192.168.x.0/24` subnets when they are created.

---

## 4. Zone membership

Each network belongs to exactly one firewall zone. 

| Network | Zone |
| --- | --- |
| Management | Internal |
| Guest | WiFi |
| Trusted | Trusted |
| WiFi | WiFi |
| DMZ | DMZ |
| Black | Black |
| Servers | Servers |

---

## 5. Switch port assignments

Switch: USW-Flex-2.5G-8-PoE (8 ports).

| Port | Role | Native network | Tagged networks |
| --- | --- | --- | --- |
| 1 | Admin port (plug in only while changing configuration, temporary) | Management | - |
| 6 | NAS | Servers | - |
| 7 | Wired client (desktop PC) | Trusted | - |
| 8 | Access point (U7 Pro XG, PoE) | Management | WiFi (20), Trusted (10) |
| 9 | Uplink to UCG-Fiber | Management | All (trunk) |
| All other ports | Unused | Black (99) | - |

Rules:

- No end device is placed on VLAN 1 other than the UniFi gear and the admin port.
- The AP port uses a custom tagged list, never *Allow All*.
- Every port not listed above is assigned to Black (VLAN 99).

---

## 6. Addressing and DHCP conventions

- **DHCP server** is enabled on every network except Black.
- **DHCP range** is limited per network. Network gear uses fixed addresses or reservations.
- **DHCP Guarding** is enabled on each network with that network's gateway as the trusted DHCP server:

| Network | Trusted DHCP server |
| --- | --- |
| Management | 192.168.1.1 |
| Trusted | 192.168.3.1 |
| WiFi | 192.168.4.1 |
| DMZ | 192.168.5.1 |
| Guest | 192.168.6.1 |
| Servers | 192.168.7.1 |
| Black | none (DHCP off) |

- **IPv6** interface type is set to *None* on all networks.
- **Isolate Network** is off. Isolation is handled by zones and firewall policies.
- **Auto Default Gateway** and **Auto DNS Server** are on.

---

## 7. Planned

- Servers VLAN (30): Add AI server
- IoT VLAN (50): smart home
- Game servers in the DMZ with port forwarding
- WireGuard VPN for remote access

---

## 8. Change log

| Date | Change |
| --- | --- |
| 2026-10 | Initial VLAN layout and port plan documented |
| 2026-10 | Added Servers vlan (30) |