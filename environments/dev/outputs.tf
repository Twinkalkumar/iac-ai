output "resource_group_id" {
  value = module.resource_group.resource_id
}

output "vnet_id" {
  value = module.vnet.resource_id
}

output "subnet_id" {
  value = module.vnet.subnets["app"].resource_id
}

output "vm_id" {
  value = module.vm.resource_id
}

output "vm_private_ip" {
  value = module.vm.virtual_machine_azurerm.private_ip_address
}

output "vm_public_ip" {
  value = var.public_ip_enabled ? module.vm.virtual_machine_azurerm.public_ip_address : null
}
