#!/usr/bin/env bash
# One-time preparation of the Proxmox host for OpenTofu. Safe to run again.
# Installs OpenTofu, creates an API token, downloads and verifies the Debian
# cloud image, and writes the shared cloud-init file.
# Run as root on the Proxmox host.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_DIR="${HOMELAB_SECRETS_DIR:-$HOME/.config/homelab}"
ENV_FILE="${SECRETS_DIR}/env"

# --- Settings ---------------------------------------------------------------
STORAGE="local"   # Needs content types: Import, Snippets
IMAGE="debian-13-genericcloud-amd64.qcow2"
IMAGE_URL="https://cloud.debian.org/images/cloud/trixie/latest"
PVE_USER="tofu@pve"
# -----------------------------------------------------------------------------

IMAGE_DIR="/var/lib/vz/import"
SNIPPET_DIR="/var/lib/vz/snippets"

for content in import snippets; do
  if ! pvesm status --content "$content" | awk '{print $1}' | grep -qx "$STORAGE"; then
    echo "Enable '${content}' on '${STORAGE}': Datacenter > Storage > Edit > Content" >&2
    exit 1
  fi
done

# OpenTofu, pinned in tools/versions.env and verified against the release checksums.
source "${REPO_ROOT}/tools/versions.env"
if [[ "$(tofu version 2>/dev/null | head -n1)" != "OpenTofu v${TOFU_VERSION}" ]]; then
  echo "Installing OpenTofu ${TOFU_VERSION}"
  tmp="$(mktemp -d)"
  base="https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}"
  archive="tofu_${TOFU_VERSION}_linux_amd64.tar.gz"
  wget -q -P "$tmp" "${base}/${archive}" "${base}/tofu_${TOFU_VERSION}_SHA256SUMS"
  (cd "$tmp" && grep " ${archive}\$" "tofu_${TOFU_VERSION}_SHA256SUMS" | sha256sum -c -)
  tar -xzf "${tmp}/${archive}" -C /usr/local/bin tofu
  rm -rf "$tmp"
fi

# API token for OpenTofu, stored outside the repository.
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"
if ! grep -qs '^PROXMOX_VE_API_TOKEN=' "$ENV_FILE"; then
  echo "Creating API token for ${PVE_USER}"
  pveum user add "$PVE_USER" --comment "OpenTofu" 2>/dev/null || true
  pveum acl modify / --users "$PVE_USER" --roles PVEAdmin
  secret="$(pveum user token add "$PVE_USER" tofu --privsep 0 --output-format json \
    | sed -n 's/.*"value" *: *"\([^"]*\)".*/\1/p')"
  [[ -n "$secret" ]] || { echo "Could not read the token secret." >&2; exit 1; }
  (
    umask 077
    {
      echo "PROXMOX_VE_ENDPOINT=https://127.0.0.1:8006/"
      echo "PROXMOX_VE_INSECURE=true"
      echo "PROXMOX_VE_API_TOKEN='${PVE_USER}!tofu=${secret}'"
    } >> "$ENV_FILE"
  )
fi

# Debian cloud image, downloaded once and verified against Debian's checksum file.
mkdir -p "$IMAGE_DIR" "$SNIPPET_DIR"
if [[ ! -f "${IMAGE_DIR}/${IMAGE}" ]]; then
  wget -q --show-progress -O "${IMAGE_DIR}/${IMAGE}" "${IMAGE_URL}/${IMAGE}"
  if ! wget -qO- "${IMAGE_URL}/SHA512SUMS" | grep " ${IMAGE}\$" | (cd "$IMAGE_DIR" && sha512sum -c -); then
    rm -f "${IMAGE_DIR}/${IMAGE}"
    echo "Checksum mismatch, image removed. Run again." >&2
    exit 1
  fi
fi

# Cloud-init vendor data, shared by every Debian VM. No secrets.
# The user, SSH key and hostname are set per VM by OpenTofu.
cat > "${SNIPPET_DIR}/debian-docker.yaml" <<'EOF'
#cloud-config
timezone: Europe/Oslo
packages:
  - qemu-guest-agent
  - unattended-upgrades
  - docker.io
  - docker-compose
  - git
write_files:
  - path: /etc/apt/apt.conf.d/20auto-upgrades
    content: |
      APT::Periodic::Update-Package-Lists "1";
      APT::Periodic::Unattended-Upgrade "1";
runcmd:
  - systemctl enable --now qemu-guest-agent
EOF

echo "Host is prepared."
