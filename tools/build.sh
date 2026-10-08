#!/usr/bin/env bash
# Builds the homelab-tools image with the versions pinned in versions.env.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

set -a
source versions.env
set +a

for v in TOFU_VERSION TALOS_VERSION KUBECTL_VERSION SOPS_VERSION AGE_VERSION FLUX_VERSION; do
  [[ -n "${!v:-}" ]] || { echo "Set ${v} in tools/versions.env" >&2; exit 1; }
done

podman build -t homelab-tools:local \
  --build-arg TOFU_VERSION \
  --build-arg TALOS_VERSION \
  --build-arg KUBECTL_VERSION \
  --build-arg SOPS_VERSION \
  --build-arg AGE_VERSION \
  --build-arg FLUX_VERSION \
  -f Containerfile .
