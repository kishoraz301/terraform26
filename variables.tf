variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-terraform-demo"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment tag (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the virtual machine. Must be 12-72 characters and include uppercase, lowercase, digit, and special character."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 12 && length(var.admin_password) <= 72
    error_message = "admin_password must be between 12 and 72 characters."
  }
}

variable "ssh_public_key" {
  description = "SSH public key for the virtual machine (recommended). When provided, password authentication is disabled."
  type        = string
  default     = null
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to the VM. Restrict to your IP for better security (e.g. '203.0.113.10/32')."
  type        = string
  default     = "*"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
