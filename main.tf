# Phase 08: Application Gateways (2 total, Standard_v2 with WAF)
# Deploy after Phase 03, 05: Subnets, Public IPs
#
# SHARED CONFIGURATION: This phase uses shared configuration from the root directory:
# - Providers: See ../../../providers.tf
# - Variables: See ../../../variables.tf  
# - Locals: See ../../../locals.tf
# For consolidation details, see ../../../CONSOLIDATION_GUIDE.md

terraform {
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

data "azurerm_resource_group" "we" {
  name = var.we_resource_group_name
}

data "azurerm_resource_group" "ne" {
  provider = azurerm.secondary
  name     = var.ne_resource_group_name
}

data "azurerm_subnet" "we_cidmz_appgw_snet" {
  name                 = "MIP-SI-WE-ciDMZ-AppGW-snet"
  virtual_network_name = "MIP-SI-WE-ciDMZ-vnet"
  resource_group_name  = data.azurerm_resource_group.we.name
}

data "azurerm_subnet" "ne_cidmz_appgw_snet" {
  provider             = azurerm.secondary
  name                 = "MIP-SI-NE-ciDMZ-AppGW-snet"
  virtual_network_name = "MIP-SI-NE-ciDMZ-vnet"
  resource_group_name  = data.azurerm_resource_group.ne.name
}

data "azurerm_public_ip" "we_appgw_pip" {
  name                = "MIP-SI-WE-AppGW-frontend-pip"
  resource_group_name = data.azurerm_resource_group.we.name
}

data "azurerm_public_ip" "ne_appgw_pip" {
  provider            = azurerm.secondary
  name                = "MIP-SI-NE-AppGW-frontend-pip"
  resource_group_name = data.azurerm_resource_group.ne.name
}

# ============================================================================
# WEST EUROPE - Application Gateway with WAF
# ============================================================================

resource "azurerm_application_gateway" "we_appgw" {
  name                = "MIP-SI-WE-ciDMZ-AppGW"
  location            = data.azurerm_resource_group.we.location
  resource_group_name = data.azurerm_resource_group.we.name
  zones               = ["1", "2", "3"]

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.appgw_autoscale_min
    max_capacity = var.appgw_autoscale_max
  }

  gateway_ip_configuration {
    name      = "MIP-SI-WE-AppGW-ipconfig"
    subnet_id = data.azurerm_subnet.we_cidmz_appgw_snet.id
  }

  frontend_ip_configuration {
    name                 = "MIP-SI-WE-AppGW-frontend"
    public_ip_address_id = data.azurerm_public_ip.we_appgw_pip.id
  }

  frontend_port {
    name = "MIP-SI-WE-HTTP-port"
    port = 80
  }

  backend_address_pool {
    name         = "MIP-SI-WE-AppBackendPool"
    ip_addresses = ["10.200.11.20", "10.200.11.21", "10.200.11.22"]
  }

  backend_http_settings {
    name                  = "MIP-SI-WE-HTTPSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 600
    pick_host_name_from_backend_address = false
    host_name             = "localhost"
    probe_name            = "MIP-SI-WE-HealthProbe"
  }

  http_listener {
    name                           = "MIP-SI-WE-HTTP-Listener"
    frontend_ip_configuration_name = "MIP-SI-WE-AppGW-frontend"
    frontend_port_name             = "MIP-SI-WE-HTTP-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name               = "MIP-SI-WE-HTTPRule"
    rule_type          = "Basic"
    http_listener_name = "MIP-SI-WE-HTTP-Listener"
    backend_address_pool_name  = "MIP-SI-WE-AppBackendPool"
    backend_http_settings_name = "MIP-SI-WE-HTTPSettings"
    priority           = 1
  }

  probe {
    name                = "MIP-SI-WE-HealthProbe"
    protocol            = "Http"
    host                = "localhost"
    path                = "/health"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    port                = 80
    pick_host_name_from_backend_http_settings = false
    match {
      status_code = ["200-399"]
    }
  }

  waf_configuration {
    enabled            = true
    firewall_mode      = var.waf_mode
    rule_set_type      = "OWASP"
    rule_set_version   = "3.1"
    file_upload_limit_mb = 100
    max_request_body_size_kb = 128
    request_body_check = true

    exclusion {
      match_variable          = "RequestHeaderNames"
      selector                = "X-Forwarded-For"
      selector_match_operator = "Equals"
    }
  }

  lifecycle {
    ignore_changes = [
      backend_http_settings
    ]
  }

  # NOTE: To add HTTPS later:
  # 1. Create Azure Key Vault with certificate
  # 2. Add ssl_certificate block with key vault reference
  # 3. Add https frontend port and https listener
  # 4. Update request_routing_rule to handle HTTPS
  # 5. Update backend_http_settings to use Https protocol on port 443
}

# ============================================================================
# NORTH EUROPE - Application Gateway with WAF
# ============================================================================

resource "azurerm_application_gateway" "ne_appgw" {
  provider            = azurerm.secondary
  name                = "MIP-SI-NE-ciDMZ-AppGW"
  location            = data.azurerm_resource_group.ne.location
  resource_group_name = data.azurerm_resource_group.ne.name
  zones               = ["1", "2", "3"]

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.appgw_autoscale_min
    max_capacity = var.appgw_autoscale_max
  }

  gateway_ip_configuration {
    name      = "MIP-SI-NE-AppGW-ipconfig"
    subnet_id = data.azurerm_subnet.ne_cidmz_appgw_snet.id
  }

  frontend_ip_configuration {
    name                 = "MIP-SI-NE-AppGW-frontend"
    public_ip_address_id = data.azurerm_public_ip.ne_appgw_pip.id
  }

  frontend_port {
    name = "MIP-SI-NE-HTTP-port"
    port = 80
  }

  backend_address_pool {
    name         = "MIP-SI-NE-AppBackendPool"
    ip_addresses = ["10.200.12.20", "10.200.12.21", "10.200.12.22"]
  }

  backend_http_settings {
    name                  = "MIP-SI-NE-HTTPSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 600
    pick_host_name_from_backend_address = false
    host_name             = "localhost"
    probe_name            = "MIP-SI-NE-HealthProbe"
  }

  http_listener {
    name                           = "MIP-SI-NE-HTTP-Listener"
    frontend_ip_configuration_name = "MIP-SI-NE-AppGW-frontend"
    frontend_port_name             = "MIP-SI-NE-HTTP-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name               = "MIP-SI-NE-HTTPRule"
    rule_type          = "Basic"
    http_listener_name = "MIP-SI-NE-HTTP-Listener"
    backend_address_pool_name  = "MIP-SI-NE-AppBackendPool"
    backend_http_settings_name = "MIP-SI-NE-HTTPSettings"
    priority           = 1
  }

  probe {
    name                = "MIP-SI-NE-HealthProbe"
    protocol            = "Http"
    host                = "localhost"
    path                = "/health"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    port                = 80
    pick_host_name_from_backend_http_settings = false
    match {
      status_code = ["200-399"]
    }
  }

  waf_configuration {
    enabled            = true
    firewall_mode      = var.waf_mode
    rule_set_type      = "OWASP"
    rule_set_version   = "3.1"
    file_upload_limit_mb = 100
    max_request_body_size_kb = 128
    request_body_check = true

    exclusion {
      match_variable          = "RequestHeaderNames"
      selector                = "X-Forwarded-For"
      selector_match_operator = "Equals"
    }
  }

  lifecycle {
    ignore_changes = [
      ssl_certificate,
      backend_http_settings
    ]
  }
}

  # NOTE: To add HTTPS later:
  # 1. Create Azure Key Vault with certificate
  # 2. Add ssl_certificate block with key vault reference
  # 3. Add https frontend port and https listener
  # 4. Update request_routing_rule to handle HTTPS
  # 5. Update backend_http_settings to use Https protocol on port 443
