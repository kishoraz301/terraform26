output "cedmz_firewall_we" {
  description = "CE DMZ Firewall Premium - West Europe details"
  value = {
    id       = azurerm_firewall.cedmz_we.id
    name     = azurerm_firewall.cedmz_we.name
    sku_tier = azurerm_firewall.cedmz_we.sku_tier
    pip      = azurerm_public_ip.cedmz_fw_pip_we.ip_address
  }
}

output "cedmz_firewall_ne" {
  description = "CE DMZ Firewall Premium - North Europe details"
  value = {
    id       = azurerm_firewall.cedmz_ne.id
    name     = azurerm_firewall.cedmz_ne.name
    sku_tier = azurerm_firewall.cedmz_ne.sku_tier
    pip      = azurerm_public_ip.cedmz_fw_pip_ne.ip_address
  }
}

output "cidmz_firewall_we" {
  description = "CI DMZ Firewall Standard - West Europe details"
  value = {
    id       = azurerm_firewall.cidmz_we.id
    name     = azurerm_firewall.cidmz_we.name
    sku_tier = azurerm_firewall.cidmz_we.sku_tier
  }
}

output "cidmz_firewall_ne" {
  description = "CI DMZ Firewall Standard - North Europe details"
  value = {
    id       = azurerm_firewall.cidmz_ne.id
    name     = azurerm_firewall.cidmz_ne.name
    sku_tier = azurerm_firewall.cidmz_ne.sku_tier
  }
}

output "cedmz_policy_we_id" {
  description = "CE DMZ Firewall Policy (WE) ID"
  value       = azurerm_firewall_policy.cedmz_policy_we.id
}

output "cedmz_policy_ne_id" {
  description = "CE DMZ Firewall Policy (NE) ID"
  value       = azurerm_firewall_policy.cedmz_policy_ne.id
}

output "cidmz_policy_we_id" {
  description = "CI DMZ Firewall Policy (WE) ID"
  value       = azurerm_firewall_policy.cidmz_policy_we.id
}

output "cidmz_policy_ne_id" {
  description = "CI DMZ Firewall Policy (NE) ID"
  value       = azurerm_firewall_policy.cidmz_policy_ne.id
}
