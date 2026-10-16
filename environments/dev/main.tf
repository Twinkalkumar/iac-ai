# Generated from requests/vm-dev-01.yaml. Do not edit by hand.

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.4.0"

  name             = var.resource_group_name
  location         = var.location
  tags             = var.tags
  enable_telemetry = false
}

module "nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.6.0"

  name             = "nsg-${var.subnet_name}"
  location         = var.location
  parent_id        = module.resource_group.resource_id
  tags             = var.tags
  enable_telemetry = false

  security_rules = {
    allow_ssh = {
      name                       = "Allow-SSH-Inbound"
      description                = "SSH from allowed source only"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = var.ssh_allowed_from
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "22"
    }
  }
}

module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.3"

  name             = var.vnet_name
  location         = var.location
  parent_id        = module.resource_group.resource_id
  address_space    = [var.vnet_address_space]
  tags             = var.tags
  enable_telemetry = false

  subnets = {
    app = {
      name             = var.subnet_name
      address_prefixes = [var.subnet_prefix]
      network_security_group = {
        id = module.nsg.resource_id
      }
    }
  }
}

module "vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.21.0"

  name                = var.vm_name
  location            = var.location
  resource_group_name = module.resource_group.name
  zone                = null
  os_type             = "Linux"
  sku_size            = var.vm_size
  tags                = var.tags
  enable_telemetry    = false

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  public_ip_configuration_details = {
    allocation_method = "Static"
    sku               = "Standard"
    tags              = var.tags
  }

  account_credentials = {
    admin_credentials = {
      username                           = var.admin_username
      ssh_keys                           = [file(pathexpand(var.ssh_public_key_path))]
      generate_admin_password_or_ssh_key = false
    }
    password_authentication_disabled = true
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  network_interfaces = {
    nic0 = {
      name = "nic-${var.vm_name}"
      ip_configurations = {
        ipconfig1 = {
          name                          = "ipconfig1"
          private_ip_subnet_resource_id = module.vnet.subnets["app"].resource_id
          create_public_ip_address      = var.public_ip_enabled
          public_ip_address_name        = var.public_ip_enabled ? "pip-${var.vm_name}" : null
        }
      }
    }
  }
}
