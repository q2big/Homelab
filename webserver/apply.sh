#!/usr/bin/env bash
# Prepares the Proxmox host and applies the OpenTofu config in this folder.
# Run as root on the Proxmox host.
# Usage: ./apply.sh            (plan, then ask before applying)
#        ./apply.sh destroy    (any other tofu command)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="${HOMELAB_SECRETS_DIR:-$HOME/.config/homelab}"
ENV_FILE="${SECRETS_DIR}/env"

"${HERE}/../proxmox/prepare.sh"

set -a
source "$ENV_FILE"
set +a

for v in TF_VAR_admin_cidr TF_VAR_ssh_public_key; do
  [[ -n "${!v:-}" ]] || { echo "Add ${v}='...' to ${ENV_FILE}" >&2; exit 1; }
done
export TF_VAR_node="$(hostname)"

cd "$HERE"
tofu init -input=false
tofu "${@:-apply}"
