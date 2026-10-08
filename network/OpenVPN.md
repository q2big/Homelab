# OpenVPN

Remote access to the NAS through the OpenVPN server on the UCG-Fiber.

## Design

- VPN clients get their own address pool and firewall zone.
- The only thing they can reach internally is file sharing (SMB) on the NAS. The NAS admin interface and all other networks are blocked.
- VPN clients cannot reach each other (client isolation).
- The VPN port is the only port open on the WAN. There is no port forwarding to internal networks.

## Users

One user per device, so a lost device can be revoked without affecting the others.

## Security notes

- The `.ovpn` profile is sensitive and is deleted from the device after import.
- Currently full tunnel: all traffic goes through the VPN while connected.
