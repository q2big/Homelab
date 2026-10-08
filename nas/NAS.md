# NAS

Synology DS925+ for file storage and backup, in its own Servers network.

## Storage

| Item | Value |
| --- | --- |
| RAID | RAID 1 |
| File system | Btrfs, data checksums on |
| Volume | Encrypted |
| Capacity | About 7.3 TiB usable |

## Network access

- Admin interface and file sharing only from Trusted and Management.
- File sharing only (no admin interface) over VPN.
- Outbound internet limited to Synology update servers and NTP, filtered by domain in UniFi.
- No port forwarding, QuickConnect or UPnP.

## Hardening

- Separate daily and admin accounts. Default accounts disabled.
- Two-factor authentication (TOTP) on the admin account.
- Auto block after failed login attempts.
- HTTPS only for the admin interface, SMB3 as minimum.
- Unused services (FTP, Telnet and similar) turned off.

## Backup and snapshots

- Btrfs snapshots on all shared folders, **immutable** for 7 days (protection against ransomware and accidental deletion).
- Frequent snapshots for documents, weekly for the backup folder.
- Proxmox VM backups are stored on the NAS.

## Planned

- Off-site copy to an external drive or the cloud (3-2-1 backup).
