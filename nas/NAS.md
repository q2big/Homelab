# NAS

Last updated: October 2026

Setup of the Synology DS925+ NAS.

---

## 1. Overview

| Item | Value |
| --- | --- |
| Model | Synology DS925+ |
| Operating system | DiskStation Manager (DSM) |
| Role | File storage and backup |
| Network | Servers (VLAN 30) |
| IP address | `192.168.7.10` (fixed, set in UniFi) |

---

## 2. Storage

| Item | Value |
| --- | --- |
| RAID type | RAID 1 |
| File system | Btrfs |
| Usable capacity | About 7.3 TiB |
| Volume | Encrypted |
| Folder settings | Data checksum on, recycle bin on, no quota (all shared folders) |

---

## 3. Network access

Enforced by the UniFi firewall. 

| Direction | Access |
| --- | --- |
| Trusted and Management to NAS | TCP 5001 (DSM HTTPS) and TCP 445 (SMB) |
| VPN to NAS | TCP 445 (SMB) only |
| NAS to Gateway | DHCP and DNS |
| NAS to internet | Only Synology domains (`synology.com`) and NTP (`no.pool.ntp.org`, UDP 123), filtered by domain in UniFi |
| Everything else | Blocked |

---

## 4. Remote access

The NAS is reached from outside through OpenVPN on the UCG-Fiber. VPN clients can only use SMB (TCP 445) to `192.168.7.10`. DSM (5001) is not reachable over VPN.

---

## 5. Security hardening

**Accounts and login**

- Two accounts: one for daily use and one admin. The default Synology accounts are deactivated.
- Two-factor authentication (TOTP) enabled for the admin account.
- Auto block enabled for failed login attempts.

**Services**

- Unused services turned off (such as FTP and Telnet).
- QuickConnect and UPnP disabled.
- DSM web interface uses HTTPS only (port 5001).
- Minimum SMB version set to SMB3.
- NTP set to `no.pool.ntp.org`.

---

## 6. Backup and snapshots

| Folder | Schedule | Protection |
| --- | --- | --- |
| Docs | Daily, every 4 hours from 10:00 to 22:00 | Immutable, 7 days |
| Backup | Weekly, Sunday 12:00 | Immutable, 7 days |

---

## 7. Maintenance

- **Updates:** DSM and package updates are downloaded through the filtered internet access to Synology domains (see section 3).

---

## 8. Planned

- Backup of the NAS to an external drive, possibly also to the cloud.

---

## 9. Change log

| Date | Change |
| --- | --- |
| 2026-10 | NAS set up with DSM 7.4.1, Btrfs and RAID 1 on the Servers VLAN (30) |
| 2026-10 | Hardened DSM: 2FA, firewall, SMB3 minimum, NTP via `no.pool.ntp.org`. Fixed IP `192.168.7.10` |
| 2026-10 | Shared folders `Docs` and `Backup` with immutable snapshots |
| 2026-10 | Remote SMB access through OpenVPN |
