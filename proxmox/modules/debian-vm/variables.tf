# --- Required ---

variable "name" {
  description = "VM name and hostname"
  type        = string
}

variable "vm_id" {
  description = "Proxmox VM ID"
  type        = number
}

variable "node" {
  description = "Proxmox node name"
  type        = string
}

variable "vlan_id" {
  description = "VLAN tag on the bridge"
  type        = number
}

variable "admin_cidr" {
  description = "Network allowed to SSH in"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for the admin user"
  type        = string
}

# --- Optional ---

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  description = "RAM in MB"
  type        = number
  default     = 2048
}

variable "disk_gb" {
  type    = number
  default = 20
}

variable "username" {
  type    = string
  default = "admin"
}

variable "bridge" {
  description = "VLAN-aware bridge"
  type        = string
  default     = "vmbr0"
}

variable "disk_storage" {
  description = "Storage for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "image" {
  description = "Cloud image placed by proxmox/prepare.sh"
  type        = string
  default     = "local:import/debian-13-genericcloud-amd64.qcow2"
}

variable "vendor_data" {
  description = "Cloud-init file placed by proxmox/prepare.sh"
  type        = string
  default     = "local:snippets/debian-docker.yaml"
}
