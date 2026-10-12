#!/usr/bin/env bash
# Run once on the Proxmox host: enables Snippets and downloads the Debian cloud image.
# Needs UniFi: Lab -> External TCP 443 to cloud.debian.org.
set -euo pipefail

IMAGE_FILE="debian-13-genericcloud-amd64.qcow2"
IMAGE_BASE="https://cloud.debian.org/images/cloud/trixie/latest"

# Enable Snippets on the 'local' storage (idempotent)
content="$(awk '$1 ~ /^[a-z]+:$/ { f = ($2 == "local"); next } f && $1 == "content" { print $2 }' /etc/pve/storage.cfg)"
if [[ ",${content}," != *",snippets,"* ]]; then
  pvesm set local --content "${content},snippets"
fi
mkdir -p /var/lib/vz/snippets
echo "OK  Snippets enabled"

# Download and verify the cloud image (once)
if [[ ! -s "/root/${IMAGE_FILE}" ]]; then
  cd /root
  wget -4 -O "$IMAGE_FILE" "${IMAGE_BASE}/${IMAGE_FILE}"
  wget -4 -O SHA512SUMS "${IMAGE_BASE}/SHA512SUMS"
  sha512sum -c SHA512SUMS --ignore-missing
fi
echo "OK  Image ready: /root/${IMAGE_FILE}"