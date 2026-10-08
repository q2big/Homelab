# Kubernetes

Last updated: October 2026

Talos Linux Kubernetes cluster on Proxmox, used for static websites.

---

## 1. Overview

| Item | Value |
| --- | --- |
| OS | [Talos Linux](https://www.talos.dev/) (immutable, no SSH or shell, managed through its API) |
| Host | Proxmox host in the Lab VLAN (50), switch port 5 |
| Network | DMZ (VLAN 40), tagged on port 5 and on the VLAN-aware bridge `vmbr0` |
| Exposure | Cloudflare Tunnel only. No inbound port forwarding |

All nodes share the DMZ VLAN because they have the same trust level. Workload isolation is handled inside Kubernetes (namespaces and NetworkPolicies).

---

## 2. Nodes

| VM ID | Name | Role | RAM | vCPU | Disk | IP (UniFi reservation) |
| --- | --- | --- | --- | --- | --- | --- |
| 201 | `talos-cp1` | Control plane | 2 GB | 2 | 16 GB | 192.168.5.11 |
| 202 | `talos-w1` | Worker | 1.5 GB | 1 | 16 GB | 192.168.5.12 |
| 203 | `talos-w2` | Worker | 1.5 GB | 1 | 16 GB | 192.168.5.13 |

Sized at the Talos minimum. Disks are thin-provisioned and can be grown later in Proxmox.

---

## 3. Setup

**1. Talos image** ([Image Factory](https://factory.talos.dev/))

| Setting | Value |
| --- | --- |
| Hardware type | Cloud Server > Nocloud |
| Architecture | amd64 |
| System extension | `siderolabs/qemu-guest-agent` |

**2. VMs**

Run [`infra/scripts/create-talos-vms.sh`](../infra/scripts/create-talos-vms.sh) in the Proxmox shell:

```bash
./create-talos-vms.sh <talos-iso-filename>
```

It creates the three VMs on VLAN 40 with the guest agent enabled and start on boot. Existing VMs are skipped. To be replaced by OpenTofu in `infra/`.

**3. Fixed IPs**

Each node boots into Talos maintenance mode and shows its DHCP address on the console. Set the fixed IPs from section 2 in UniFi (Clients) and reboot the VMs.

**4. Cluster config and bootstrap**

[`infra/talos/patch.yaml`](../infra/talos/patch.yaml) sets the Image Factory installer (keeps the guest agent after install), the install disk `/dev/sda`, and NTP to `no.pool.ntp.org` without NTS. Run from the repo root in a host terminal:

```bash
tools/run.sh talosctl gen secrets -o /secrets/secrets.yaml   # once
tools/run.sh talosctl gen config homelab https://192.168.5.11:6443 \
  --with-secrets /secrets/secrets.yaml \
  --config-patch @infra/talos/patch.yaml \
  --output _out
tools/run.sh talosctl apply-config --insecure -n 192.168.5.11 -f _out/controlplane.yaml
tools/run.sh talosctl apply-config --insecure -n 192.168.5.12 -f _out/worker.yaml
tools/run.sh talosctl apply-config --insecure -n 192.168.5.13 -f _out/worker.yaml

T="--talosconfig _out/talosconfig"
tools/run.sh talosctl $T config endpoint 192.168.5.11
tools/run.sh talosctl $T config node 192.168.5.11
tools/run.sh talosctl $T bootstrap                            # once
tools/run.sh talosctl $T kubeconfig _out/kubeconfig
tools/run.sh kubectl --kubeconfig _out/kubeconfig get nodes
```

`secrets.yaml` is stored in `~/.config/homelab/`. `talosconfig` and `kubeconfig` are in `_out/` (ignored by Git). Back up all three in the password manager.

Notes:

- Talos 1.14 uses the `UnattendedInstallConfig` document. Patching `machine.install` fails with "incompatible with v1alpha1 config".

---

## 4. Firewall

| From | To | Allowed |
| --- | --- | --- |
| Trusted | DMZ | TCP 50000 (Talos API), TCP 6443 (Kubernetes API) |
| DMZ | External | TCP 80/443 (image pulls, updates), UDP 123 (NTP to `no.pool.ntp.org`) |
| DMZ | External | TCP 443 to `ssh.github.com` (Flux Git over SSH), `ghcr.io` and `pkg-containers.githubusercontent.com` (Flux images) |
| DMZ | Gateway | DNS (TCP/UDP 53) and DHCP |

Everything else from the DMZ is blocked, including the NAS and all internal networks.

---

## 5. GitOps (Flux)

Flux runs in the cluster and keeps it in sync with [`clusters/homelab/`](../clusters/homelab/) in this repository. A change pushed to `main` is applied within a minute.

| Item | Value |
| --- | --- |
| Repository | `q2big/Homelab`, branch `main`, path `clusters/homelab` |
| Access | Read-only deploy key (GitHub > Settings > Deploy keys) |
| Git transport | SSH over port 443 (`ssh.github.com:443`), so the DMZ needs no port 22 |

Bootstrap (once, with a short-lived fine-grained GitHub token in `~/.config/homelab/env` as `GITHUB_TOKEN`, permissions Contents and Administration read/write on this repo only):

```bash
tools/run.sh flux bootstrap github \
  --kubeconfig _out/kubeconfig \
  --owner=q2big --repository=Homelab --branch=main \
  --path=clusters/homelab --personal \
  --ssh-hostname=ssh.github.com:443
```

The token is only used during bootstrap (to push the Flux manifests and create the deploy key) and is deleted afterwards.


---

## 6. Planned

- Cilium as CNI, with NetworkPolicies so only Flux can reach GitHub and the websites get no egress.
- Websites in a separate private repository, deployed by Flux.
- Cloudflare Tunnel for public access.

---

## 7. Change log

| Date | Change |
| --- | --- |
| 2026-10 | Talos VMs (201-203) planned in the DMZ on the Proxmox host |
| 2026-10 | Cluster bootstrapped (Talos v1.14.2, Kubernetes v1.37.1). NTP set to `no.pool.ntp.org` |
| 2026-10 | Flux bootstrapped from `clusters/homelab` with a read-only deploy key |
