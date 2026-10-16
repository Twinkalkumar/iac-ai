# Defaults come from requests/vm-dev-01.yaml.

variable "resource_group_name" {
  type    = string
  default = "rg-dev-centralindia"
}

variable "location" {
  type    = string
  default = "centralindia"
}

variable "vnet_name" {
  type    = string
  default = "vnet-dev"
}

variable "vnet_address_space" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnet_name" {
  type    = string
  default = "snet-app"
}

variable "subnet_prefix" {
  type    = string
  default = "10.10.1.0/24"
}

variable "ssh_allowed_from" {
  type        = string
  description = "Source CIDR allowed to SSH to the VM."
  default     = "104.30.167.32/32"
}

variable "public_ip_enabled" {
  type        = bool
  description = "Create a public IP for the VM (request: public_ip)."
  default     = true
}

variable "vm_name" {
  type    = string
  default = "vm-dev-01"
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key (never the private key)."
  default     = "~/.ssh/id_rsa.pub"
}

variable "os_disk_type" {
  type    = string
  default = "StandardSSD_LRS"
}

variable "os_disk_size_gb" {
  type    = number
  default = 128
}

variable "tags" {
  type = map(string)
  default = {
    owner       = "team-a"
    env         = "dev"
    cost_center = "cc-1234"
  }
}
