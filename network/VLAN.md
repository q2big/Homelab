# VLANs & Topology

Segmented home network on UniFi (UCG-Fiber gateway, USW-Flex 2.5G PoE switch, U7 Pro XG access point).

## Design principles

- **Segmentation by function.** Every use case has its own VLAN and subnet, mapped to its own firewall zone.
- **Isolated management.** The management VLAN carries only network gear. No clients live there.
- **Black hole VLAN.** All unused switch ports are assigned to a VLAN with no DHCP, no gateway access and no internet.
- **Internet-exposed services live in the DMZ** and have no route into any internal network.
- **IPv6 disabled** on all networks until it is planned and filtered.
- **DHCP Guarding** on every network, trusting only that network's gateway.

## Logical view

```
                                  Internet
                                     |
                               [ UCG-Fiber ]
                                     |
   +-----------+-----------+-----------+-----------+-----------+-----------+-----------+
   |           |           |           |           |           |           |           |
Management   Trusted      WiFi        Guest       DMZ        Servers      Lab        Black
(net gear)   (personal    (internet   (visitors)  (exposed    (NAS)       (Proxmox    (unused
             devices)     only)                   websites)               host)       ports)

   Remote access: OpenVPN clients in their own VPN zone (not a VLAN)
```

## Networks

| Network | Purpose | Status |
| --- | --- | --- |
| Management | UniFi gear only | Active |
| Trusted | Personal devices (wired, and Wi-Fi users mapped by RADIUS) | Active |
| WiFi | Wi-Fi clients with minimal rights (internet only) | Active |
| Servers | NAS | Active |
| DMZ | Internet-exposed websites | Active |
| Lab | Proxmox host | Active |
| Guest | Visitors | VLAN created, not in use yet |
| Black | Black hole for unused ports | Active |
| VPN | OpenVPN remote access clients | Active |
| IoT | Smart home devices | Planned |

## Switching

- Access ports carry one untagged network. Only the AP, the Proxmox host and the uplink are trunks.
- Trunk ports use a custom tagged list, never *Allow All*.
- The Proxmox host is native on Lab, with the DMZ tagged for its VMs (VLAN-aware bridge).
- Every unused port is assigned to Black.

## Planned

- AI server in the Servers network
- IoT network for smart home devices
