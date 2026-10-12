#!/usr/bin/env bash
# Run on the Proxmox host after prepare-host.sh. Creates and starts the Minecraft VM.
set -Eeuo pipefail
trap 'echo "ERROR at line ${LINENO}: ${BASH_COMMAND}" >&2' ERR

### Settings
VMID=220
VM_NAME="minecraft"
VM_IP="192.168.5.20/24"
GATEWAY="192.168.5.1"
VLAN=40
MEMORY=5120
CORES=2
DISK_GB=20
DISK_STORAGE="local-lvm"
###

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="/root/debian-13-genericcloud-amd64.qcow2"
SNIPPET="/var/lib/vz/snippets/minecraft-user.yaml"

fail() { echo "FAIL  $*" >&2; exit 1; }

# --- Checks ---
[[ -f "$IMAGE" ]] || fail "Image missing: $IMAGE (run prepare-host.sh first)"
[[ -s "$IMAGE" ]] || fail "Image is empty: $IMAGE"
[[ -f "$DIR/cloud-init.yaml" ]] || fail "cloud-init.yaml missing in $DIR"
grep -q '<your-\|<paste' "$DIR/cloud-init.yaml" && fail "Edit cloud-init.yaml first (placeholders remain)"
pvesm status | awk 'NR>1 {print $1}' | grep -qx "$DISK_STORAGE" || fail "Storage '${DISK_STORAGE}' not found (pvesm status)"
qm status "$VMID" >/dev/null 2>&1 && fail "VM ${VMID} exists. Remove it: qm stop ${VMID}; qm destroy ${VMID} --purge"
echo "OK    Checks passed"

# --- cloud-init file ---
mkdir -p "$(dirname "$SNIPPET")"
cp "$DIR/cloud-init.yaml" "$SNIPPET"
echo "OK    cloud-init file copied"

# --- Create the VM ---
qm create "$VMID" \
  --name "$VM_NAME" \
  --memory "$MEMORY" --cores "$CORES" --cpu host \
  --machine q35 --ostype l26 \
  --scsihw virtio-scsi-single \
  --net0 "virtio,bridge=vmbr0,tag=${VLAN}" \
  --agent enabled=1 \
  --onboot 1
echo "OK    VM created"

# --- World storage: Proxmox directory shared into the VM (virtiofs) ---
WORLD_DIR=/var/lib/vz/mcworlds
WORLD_MAP=mcworlds

mkdir -p "$WORLD_DIR/vanilla" "$WORLD_DIR/modded"
chown -R 1000:1000 "$WORLD_DIR"

pvesh get "/cluster/mapping/dir/$WORLD_MAP" >/dev/null 2>&1 || \
  pvesh create /cluster/mapping/dir --id "$WORLD_MAP" \
    --map "node=$(hostname),path=$WORLD_DIR"

qm set "$VMID" --virtiofs0 "$WORLD_MAP"
echo "OK  World directory shared: $WORLD_DIR"

# --- Import the cloud image as the boot disk ---
qm importdisk "$VMID" "$IMAGE" "$DISK_STORAGE"
VOL="$(qm config "$VMID" | awk -F': ' '/^unused0:/ {print $2}')"
[[ -n "$VOL" ]] || fail "Disk import produced no unused0 volume"
qm set "$VMID" --scsi0 "${VOL},discard=on,ssd=1"
qm set "$VMID" --boot order=scsi0
qm resize "$VMID" scsi0 "${DISK_GB}G"
echo "OK    Boot disk attached (${VOL})"

# --- cloud-init drive and settings ---
qm set "$VMID" --ide2 "${DISK_STORAGE}:cloudinit"
qm set "$VMID" --ipconfig0 "ip=${VM_IP},gw=${GATEWAY}" --nameserver "$GATEWAY"
qm set "$VMID" --cicustom "user=local:snippets/minecraft-user.yaml"
echo "OK    cloud-init configured"

# --- Verify before starting ---
for key in scsi0 ide2 ipconfig0 cicustom; do
  qm config "$VMID" | grep -q "^${key}:" || fail "Missing '${key}' in VM config"
done
qm config "$VMID" | grep -q '^boot: order=scsi0' || fail "Boot order is not scsi0"
echo "OK    Config verified"

qm start "$VMID"
echo "OK    VM ${VMID} started. Wait 3-5 minutes for cloud-init, then run:"
echo "      qm guest exec ${VMID} -- cloud-init status"