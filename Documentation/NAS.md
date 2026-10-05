# NAS

Last updated: October 2026

Setup of the Synology DS925+ NAS.

---

## 1. Overview

| Item | Value |
| --- | --- |
| Model | Synology DS925+ |
| Operating system | DiskStation Manager (DSM)|
| Role | File storage and backup. Docker and VMs are possible later |
| Network | Servers (VLAN 30), `192.168.7.0/24` |
| Switch port | Port 6 (native Servers, no tagging) |
| IP address | TBD (DHCP reservation in the Servers network) |

---

## 2. Storage

| Item | Value |
| --- | --- |
| Drives | 2 x 8 TB HDD |
| RAID type | RAID 1 |
| File system | Btrfs |

Notes:

- RAID 1 protects against one drive failing. It is not meant for backup. I am planning to add an external drive later (Maybe cloud backups?) for backing up my NAS.

---

## 3. Network access

- DSM is reached at `https://<NAS IP>:5001` from the Trusted network.
- Synology Assistant does not work across VLANs, so the IP address is used directly.
- No port forwarding to the NAS and no inbound access from the internet.
- No Synology Account, QuickConnect and UPnP disabled. Planning to implement WireGuard.

---

## 4. Security hardening (to-do)

- Create a local admin account and disable the default `admin` and `guest` accounts
- Enable two-factor authentication for the admin account
- Enable auto block for failed logins
- Set the minimum SMB version to SMB3 and disable SMB1
- Disable unused services (FTP, Telnet, and SSH when not needed)
- Enable automatic DSM security updates

---

## 5. Backup and snapshots (to-do)

- **Snapshots:** Btrfs snapshots on shared folders with a retention schedule (TBD).
- **Backup:** at least one copy on a separate device, with one copy stored offline or off-site (3-2-1 rule).

| Item | Value |
| --- | --- |
| Snapshot schedule | TBD |
| Backup target | TBD |
| Last restore test | TBD |

---

## 6. Maintenance

- **Updates:** DSM and package updates uses the website-filtered internet access to Synology domains.

---


## 7. Change log

| Date | Change |
| --- | --- |
| 2026-10 | NAS set up with DSM 7.4.1, Btrfs and RAID 1 on the Servers VLAN (30) |