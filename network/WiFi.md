# Wi-Fi

One WPA3-Enterprise SSID where the login decides the network (U7 Pro XG with built-in UniFi RADIUS).

## Goal

Everyone on Wi-Fi gets minimal rights (internet only), except my own devices, which get Trusted access. Instead of separate SSIDs with shared passwords, one SSID uses RADIUS to place each user in the right VLAN.

## How it works

1. A device connects to the SSID and logs in with a username and password.
2. RADIUS returns the VLAN for that user (dynamic VLAN assignment).
3. The AP places the client on that VLAN, and it gets an address from that network.
4. The firewall zone for that network decides what the client can reach.

| User | Network | Result |
| --- | --- | --- |
| Personal | Trusted | Same access as my wired devices |
| Everyone else | WiFi | Internet only |

The AP itself stays on the management network and only carries the Wi-Fi VLANs tagged.

## Planned

- Guest and IoT SSIDs
- Certificate-based authentication per device instead of shared users
