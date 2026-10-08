# Kubernetes

Three-node Talos Linux cluster on Proxmox with Flux GitOps, built as a learning environment.

**Status:** Paused. The VMs are deleted and the websites moved to a simpler Docker Compose setup (see [webserver](../webserver/WEBSERVER.md)). The config in this folder is kept for a rebuild.

## Stack

| Part | Choice | Why |
| --- | --- | --- |
| OS | [Talos Linux](https://www.talos.dev/) | Immutable and minimal, no SSH or shell, managed only through an authenticated API |
| Nodes | 1 control plane, 2 workers | Smallest setup that still shows scheduling across nodes |
| Network | DMZ | Same trust level for all nodes, isolated from internal networks |
| GitOps | Flux | The cluster follows this repository. A push to `main` is applied automatically |
| Tooling | Podman toolbox (see [tools](../tools/TOOLING.md)) | Pinned versions of talosctl, kubectl and Flux |

## What I did

- Built a custom Talos image with Image Factory (QEMU guest agent extension).
- Created the VMs with a script ([`scripts/create-talos-vms.sh`](scripts/create-talos-vms.sh)) on a VLAN-aware Proxmox bridge.
- Generated the cluster config with a patch ([`talos/patch.yaml`](talos/patch.yaml)) for the installer image, the install disk and NTP.
- Bootstrapped etcd and the control plane, and joined the workers.
- Bootstrapped Flux from [`clusters/homelab/`](clusters/homelab/) with a **read-only deploy key**. The GitHub token was short-lived and limited to this repository.
- Limited admin access to Trusted, and DMZ egress to the domains the cluster needs.

## Lessons learned

- **Talos 1.14 changed the config format.** Install settings moved to a separate `UnattendedInstallConfig` document, so older guides fail.
- **Time sync blocks the boot.** Talos uses NTS (encrypted NTP) by default. The firewall blocked it, so etcd never started. Switching to plain NTP against an allowed server fixed it. The logs (`talosctl dmesg`) showed the cause right away.
- **A firewall cannot filter per repository.** Git traffic is encrypted, so UniFi only sees the domain. Access to one repo is limited by the deploy key, and per-workload egress would need NetworkPolicies.

## Ideas for a rebuild

- Cilium as CNI, so NetworkPolicies are enforced (Flannel ignores them).
