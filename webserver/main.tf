# Webserver VM in the DMZ. Apply with ./apply.sh on the Proxmox host.

terraform {
  required_version = ">= 1.8"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.116"
    }
  }
}

# Endpoint and API token come from the PROXMOX_VE_* environment variables.
provider "proxmox" {}

# Set by apply.sh and the secrets file, so no addresses or keys live in Git.
variable "node" {
  type = string
}

variable "admin_cidr" {
  description = "Trusted network, allowed to SSH in"
  type        = string
}

variable "ssh_public_key" {
  type = string
}

module "web" {
  source = "../proxmox/modules/debian-vm"

  name    = "web"
  vm_id   = 110
  vlan_id = 40 # DMZ

  node           = var.node
  admin_cidr     = var.admin_cidr
  ssh_public_key = var.ssh_public_key
}

output "web_ip" {
  value = module.web.ipv4_addresses
}
