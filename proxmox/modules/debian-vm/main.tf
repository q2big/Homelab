# Debian VM with Docker, created from the cloud image that proxmox/prepare.sh
# downloaded and verified. Reusable: one module block per VM.

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.116"
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name      = var.name
  node_name = var.node
  vm_id     = var.vm_id
  on_boot   = true

  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"

  # UEFI with Secure Boot
  efi_disk {
    datastore_id      = var.disk_storage
    type              = "4m"
    pre_enrolled_keys = true
  }

  operating_system {
    type = "l26"
  }

  # Installed by cloud-init on first boot. OpenTofu waits for it to report the address.
  agent {
    enabled = true
  }

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.disk_storage
    import_from  = var.image
    interface    = "scsi0"
    size         = var.disk_gb
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge   = var.bridge
    vlan_id  = var.vlan_id
    firewall = true
  }

  serial_device {}

  initialization {
    datastore_id = var.disk_storage

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    # Key-only login. The user has no password.
    user_account {
      username = var.username
      keys     = [trimspace(var.ssh_public_key)]
    }

    vendor_data_file_id = var.vendor_data
  }
}

# Proxmox firewall for this VM: drop all inbound except SSH from the admin network.
# Takes effect only when the firewall is also enabled under Datacenter > Firewall.
resource "proxmox_virtual_environment_firewall_options" "this" {
  node_name     = var.node
  vm_id         = proxmox_virtual_environment_vm.this.vm_id
  enabled       = true
  dhcp          = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"
}

resource "proxmox_virtual_environment_firewall_rules" "this" {
  node_name = var.node
  vm_id     = proxmox_virtual_environment_vm.this.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    macro   = "SSH"
    source  = var.admin_cidr
    comment = "SSH from the admin network"
  }
}
