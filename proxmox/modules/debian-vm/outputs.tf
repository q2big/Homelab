output "vm_id" {
  value = proxmox_virtual_environment_vm.this.vm_id
}

output "ipv4_addresses" {
  description = "Addresses reported by the guest agent"
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses
}
