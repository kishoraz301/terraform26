variable "primary_subscription_id" {
  description = "Azure subscription ID for primary region"
  type        = string
  sensitive   = true
}

variable "secondary_subscription_id" {
  description = "Azure subscription ID for secondary region"
  type        = string
  sensitive   = true
}

variable "primary_region" {
  description = "Primary Azure region"
  type        = string
  default     = "westeurope"
}

variable "secondary_region" {
  description = "Secondary Azure region"
  type        = string
  default     = "northeurope"
}

# Resource Group Names
variable "primary_rg_name" {
  description = "Primary region resource group name"
  type        = string
}

variable "secondary_rg_name" {
  description = "Secondary region resource group name"
  type        = string
}

# VNet Names
variable "cedmz_vnet_we" {
  description = "CE DMZ Virtual Network name - West Europe"
  type        = string
  default     = "MIP-SI-ceDMZ-WE-vnet"
}

variable "cedmz_vnet_ne" {
  description = "CE DMZ Virtual Network name - North Europe"
  type        = string
  default     = "MIP-SI-ceDMZ-NE-vnet"
}

variable "cidmz_vnet_we" {
  description = "CI DMZ Virtual Network name - West Europe"
  type        = string
  default     = "MIP-SI-DMZ-WE-vnet"
}

variable "cidmz_vnet_ne" {
  description = "CI DMZ Virtual Network name - North Europe"
  type        = string
  default     = "MIP-SI-DMZ-NE-vnet"
}

# Subnet Names for Firewalls
variable "cedmz_fw_subnet_we" {
  description = "CE DMZ Firewall Subnet name - West Europe"
  type        = string
  default     = "AzureFirewallSubnet"
}

variable "cedmz_fw_subnet_ne" {
  description = "CE DMZ Firewall Subnet name - North Europe"
  type        = string
  default     = "AzureFirewallSubnet"
}

variable "cidmz_fw_subnet_we" {
  description = "CI DMZ Firewall Subnet name - West Europe"
  type        = string
  default     = "AzureFirewallSubnet"
}

variable "cidmz_fw_subnet_ne" {
  description = "CI DMZ Firewall Subnet name - North Europe"
  type        = string
  default     = "AzureFirewallSubnet"
}
