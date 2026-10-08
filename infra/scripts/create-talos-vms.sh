#!/usr/bin/env bash
# Creates the Talos Linux VMs for the DMZ Kubernetes cluster on Proxmox.
# Usage: ./create-talos-vms.sh <talos-iso-filename>
# Example: ./create-talos-vms.sh nocloud-amd64.iso
set -euo pipefail

ISO="${1:?Usage: $0 <talos-iso-filename>}"

# --- Settings ---------------------------------------------------------------
ISO_STORAGE="local"       # Storage that holds the ISO
DISK_STORAGE="local-lvm"  # Storage for VM disks (check with: pvesm status)
BRIDGE="vmbr0"            # VLAN-aware bridge
VLAN=40                   # DMZ
DISK_GB=16
# -----------------------------------------------------------------------------

if [[ ! -f "/var/lib/vz/template/iso/${ISO}" ]]; then
  echo "ISO not found: /var/lib/vz/template/iso/${ISO}" >&2
  echo "Available ISOs:" >&2
  ls /var/lib/vz/template/iso/ >&2
  exit 1
fi

create_vm() {
  local id="$1" name="$2" memory="$3" cores="$4"

  if qm status "$id" >/dev/null 2>&1; then
    echo "VM ${id} (${name}) already exists, skipping."
    return
  fi

  echo "Creating VM ${id} (${name}): ${memory} MB RAM, ${cores} vCPU"
  qm create "$id" \
    --name "$name" \
    --memory "$memory" --cores "$cores" --cpu host \
    --machine q35 --ostype l26 \
    --scsihw virtio-scsi-single \
    --scsi0 "${DISK_STORAGE}:${DISK_GB},discard=on,ssd=1" \
    --net0 "virtio,bridge=${BRIDGE},tag=${VLAN}" \
    --ide2 "${ISO_STORAGE}:iso/${ISO},media=cdrom" \
    --boot "order=scsi0;ide2" \
    --agent enabled=1 \
    --onboot 1
}

#           ID   NAME        RAM(MB) vCPU
create_vm  201  talos-cp1   2048    2
create_vm  202  talos-w1    1536    1
create_vm  203  talos-w2    1536    1

for id in 201 202 203; do
  qm start "$id"
done

echo "Done. Open each VM console to read its DHCP address."
