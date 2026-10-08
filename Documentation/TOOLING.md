# Tooling

Last updated: October 2026

## Admin toolbox (Podman)

All infrastructure tooling runs in a Podman container, so every machine gets the same pinned tool versions and nothing is installed on the host except Podman.

| Tool | Purpose |
|---|---|
| OpenTofu | Creates the Proxmox VMs and the Talos cluster |
| talosctl | Talos Linux management API |
| kubectl | Kubernetes API |
| Flux CLI | GitOps bootstrap |
| SOPS + age | Encrypts secrets stored in Git |

### Files

| File | Purpose |
|---|---|
| `tools/versions.env` | Pinned tool versions |
| `tools/Containerfile` | Image definition |
| `tools/build.sh` | Builds the image from `versions.env` |
| `tools/run.sh` | Runs a command in the container |

### Usage

```bash
tools/build.sh          # build or rebuild after changing versions
tools/run.sh tofu plan  # run any tool in the container
tools/run.sh            # interactive shell
```

The repository is mounted at `/work` and secrets at `/secrets`. Secrets live outside the repository in `~/.config/homelab/` (age key and an `env` file for API tokens) and are never committed.

### Notes

- `TALOS_VERSION` must match the Talos version of the installed image.
- On Fedora (SELinux), volumes are mounted with `:Z`.
- The admin machine must be in the Trusted VLAN, which is allowed to reach the Proxmox API (TCP 8006, 22) and the Talos and Kubernetes APIs in the DMZ (TCP 50000, 6443).
- Back up `age.key` outside the machine (password manager). Without it, SOPS-encrypted files cannot be decrypted.
