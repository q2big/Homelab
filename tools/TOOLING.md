# Tooling

All infrastructure tooling runs in a Podman container. Every machine gets the same pinned versions, and nothing is installed on the host except Podman.

| Tool | Purpose |
| --- | --- |
| OpenTofu | Infrastructure as code |
| talosctl | Talos Linux API |
| kubectl | Kubernetes API |
| Flux CLI | GitOps bootstrap |
| SOPS + age | Encrypted secrets in Git |

## Files

| File | Purpose |
| --- | --- |
| `versions.env` | Pinned tool versions |
| `Containerfile` | Image definition (Debian slim) |
| `build.sh` | Builds the image from `versions.env` |
| `run.sh` | Runs a command in the container |

## Usage

```bash
tools/build.sh          # build or rebuild after changing versions
tools/run.sh tofu plan  # run any tool in the container
tools/run.sh            # interactive shell
```

## Design

- The repository is mounted into the container. Secrets are mounted from a folder outside the repository and are never committed.
- Files created in the container are owned by my user (`--userns=keep-id`), and volumes work with SELinux on Fedora (`:Z`).
- `.gitignore` keeps Terraform state, cluster configs and keys out of Git.
