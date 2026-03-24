terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.primary_subscription_id
}

provider "azurerm" {
  alias           = "secondary"
  features {}
  subscription_id = var.secondary_subscription_id
}

# ============================================================================
# Data Sources
# ============================================================================

# Primary Region Resources
data "azurerm_resource_group" "primary" {
  name = var.primary_rg_name
}

data "azurerm_virtual_network" "cedmz_primary" {
  name                = var.cedmz_vnet_we
  resource_group_name = data.azurerm_resource_group.primary.name
}

data "azurerm_virtual_network" "cidmz_primary" {
  name                = var.cidmz_vnet_we
  resource_group_name = data.azurerm_resource_group.primary.name
}

data "azurerm_subnet" "cedmz_fw_primary" {
  name                 = var.cedmz_fw_subnet_we
  virtual_network_name = data.azurerm_virtual_network.cedmz_primary.name
  resource_group_name  = data.azurerm_resource_group.primary.name
}

data "azurerm_subnet" "cidmz_fw_primary" {
  name                 = var.cidmz_fw_subnet_we
  virtual_network_name = data.azurerm_virtual_network.cidmz_primary.name
  resource_group_name  = data.azurerm_resource_group.primary.name
}

# Secondary Region Resources
data "azurerm_resource_group" "secondary" {
  provider = azurerm.secondary
  name     = var.secondary_rg_name
}

data "azurerm_virtual_network" "cedmz_secondary" {
  provider            = azurerm.secondary
  name                = var.cedmz_vnet_ne
  resource_group_name = data.azurerm_resource_group.secondary.name
}

data "azurerm_virtual_network" "cidmz_secondary" {
  provider            = azurerm.secondary
  name                = var.cidmz_vnet_ne
  resource_group_name = data.azurerm_resource_group.secondary.name
}

data "azurerm_subnet" "cedmz_fw_secondary" {
  provider             = azurerm.secondary
  name                 = var.cedmz_fw_subnet_ne
  virtual_network_name = data.azurerm_virtual_network.cedmz_secondary.name
  resource_group_name  = data.azurerm_resource_group.secondary.name
}

data "azurerm_subnet" "cidmz_fw_secondary" {
  provider             = azurerm.secondary
  name                 = var.cidmz_fw_subnet_ne
  virtual_network_name = data.azurerm_virtual_network.cidmz_secondary.name
  resource_group_name  = data.azurerm_resource_group.secondary.name
}

# ============================================================================
# CE DMZ Azure Firewall Premium - West Europe
# ============================================================================

resource "azurerm_public_ip" "cedmz_fw_pip_we" {
  name                = "SI-CEDMZ-WE-FW-01-PIP"
  location            = var.primary_region
  resource_group_name = data.azurerm_resource_group.primary.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_firewall_policy" "cedmz_policy_we" {
  name                = "SI-CEDMZ-FWPLCY-01"
  location            = var.primary_region
  resource_group_name = data.azurerm_resource_group.primary.name
  sku                 = "Premium"
}

resource "azurerm_firewall" "cedmz_we" {
  name                = "SI-CEDMZ-WE-FW-01"
  location            = var.primary_region
  resource_group_name = data.azurerm_resource_group.primary.name
  sku_tier            = "Premium"
  sku_name            = "AZFW_VNet"
  firewall_policy_id  = azurerm_firewall_policy.cedmz_policy_we.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.cedmz_fw_primary.id
    public_ip_address_id = azurerm_public_ip.cedmz_fw_pip_we.id
  }

  zones = ["1"]
}

# ============================================================================
# CE DMZ Azure Firewall Premium - North Europe
# ============================================================================

resource "azurerm_public_ip" "cedmz_fw_pip_ne" {
  provider            = azurerm.secondary
  name                = "SI-CEDMZ-NE-FW-51-PIP"
  location            = var.secondary_region
  resource_group_name = data.azurerm_resource_group.secondary.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_firewall_policy" "cedmz_policy_ne" {
  provider            = azurerm.secondary
  name                = "SI-CEDMZ-FWPLCY-51"
  location            = var.secondary_region
  resource_group_name = data.azurerm_resource_group.secondary.name
  sku                 = "Premium"
}

resource "azurerm_firewall" "cedmz_ne" {
  provider            = azurerm.secondary
  name                = "SI-CEDMZ-NE-FW-51"
  location            = var.secondary_region
  resource_group_name = data.azurerm_resource_group.secondary.name
  sku_tier            = "Premium"
  sku_name            = "AZFW_VNet"
  firewall_policy_id  = azurerm_firewall_policy.cedmz_policy_ne.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.cedmz_fw_secondary.id
    public_ip_address_id = azurerm_public_ip.cedmz_fw_pip_ne.id
  }

  zones = ["1"]
}

# ============================================================================
# CI DMZ Azure Firewall Standard - West Europe
# ============================================================================

resource "azurerm_firewall_policy" "cidmz_policy_we" {
  name                = "SI-CIDMZ-FWPLCY-WE-STD"
  location            = var.primary_region
  resource_group_name = data.azurerm_resource_group.primary.name
  sku                 = "Standard"
}

resource "azurerm_firewall" "cidmz_we" {
  name                = "SI-DMZ-WE-FWSTD-01"
  location            = var.primary_region
  resource_group_name = data.azurerm_resource_group.primary.name
  sku_tier            = "Standard"
  sku_name            = "AZFW_VNet"
  firewall_policy_id  = azurerm_firewall_policy.cidmz_policy_we.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.cidmz_fw_primary.id
  }

  zones = ["1"]
}

# ============================================================================
# CI DMZ Azure Firewall Standard - North Europe
# ============================================================================

resource "azurerm_firewall_policy" "cidmz_policy_ne" {
  provider            = azurerm.secondary
  name                = "SI-CIDMZ-FWPLCY-NE-STD"
  location            = var.secondary_region
  resource_group_name = data.azurerm_resource_group.secondary.name
  sku                 = "Standard"
}

resource "azurerm_firewall" "cidmz_ne" {
  provider            = azurerm.secondary
  name                = "SI-DMZ-NE-FWSTD-51"
  location            = var.secondary_region
  resource_group_name = data.azurerm_resource_group.secondary.name
  sku_tier            = "Standard"
  sku_name            = "AZFW_VNet"
  firewall_policy_id  = azurerm_firewall_policy.cidmz_policy_ne.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.cidmz_fw_secondary.id
  }

  zones = ["1"]
}
