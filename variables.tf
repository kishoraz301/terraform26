variable "primary_subscription_id" {
  type      = string
  sensitive = true
}

variable "secondary_subscription_id" {
  type      = string
  sensitive = true
}

variable "primary_region" {
  type    = string
  default = "westeurope"
  description = "Primary region for West Europe resources"
}

variable "secondary_region" {
  type    = string
  default = "northeurope"
  description = "Secondary region for North Europe resources"
}

variable "environment" {
  type    = string
  default = "production"
  description = "Environment name (production, staging, etc)"
}

variable "we_resource_group_name" {
  type    = string
  default = "MIP-SI-WE-RG"
}

variable "ne_resource_group_name" {
  type    = string
  default = "MIP-SI-NE-RG"
}

# ============================================================================
# VIRTUAL NETWORK & SUBNET CONFIGURATION
# ============================================================================

variable "we_vnet_name" {
  type    = string
  default = "MIP-SI-WE-ciDMZ-vnet"
}

variable "ne_vnet_name" {
  type    = string
  default = "MIP-SI-NE-ciDMZ-vnet"
}

variable "we_proxy_subnet_name" {
  type    = string
  default = "MIP-SI-WE-ciDMZ-Proxy-dmz-snet"
}

variable "ne_proxy_subnet_name" {
  type    = string
  default = "MIP-SI-NE-ciDMZ-Proxy-dmz-snet"
}

variable "we_rds_subnet_name" {
  type    = string
  default = "MIP-SI-WE-ciDMZ-RDS-snet"
}

variable "ne_rds_subnet_name" {
  type    = string
  default = "MIP-SI-NE-ciDMZ-RDS-snet"
}

# ============================================================================
# LOG ANALYTICS WORKSPACE CONFIGURATION
# ============================================================================

variable "we_log_analytics_workspace_name" {
  type    = string
  default = "LogA-WE"
}

variable "we_log_analytics_rg_name" {
  type    = string
  default = "la-we-rg"
  description = "Resource group where Log Analytics workspace LogA-WE is located"
}

variable "ne_log_analytics_workspace_name" {
  type    = string
  default = "LogA-WE"
  description = "NE Log Analytics Workspace (shared with WE per requirement)"
}

variable "ne_log_analytics_rg_name" {
  type    = string
  default = "la-we-rg"
  description = "Resource group for NE Log Analytics (shared with WE)"
}

# ============================================================================
# LOAD BALANCER PROBE CONFIGURATION
# ============================================================================

variable "lb_probe_interval" {
  type    = number
  default = 15
  description = "Interval (in seconds) between health probes"
}

variable "lb_probe_threshold" {
  type    = number
  default = 2
  description = "Number of consecutive probes that must fail before marking backend unhealthy"
}

# ============================================================================
# BACKEND MEMBER CONFIGURATION - SQUID PROD
# ============================================================================

variable "we_squid_prod_backend_ips" {
  type    = list(string)
  default = ["10.200.11.35", "10.200.11.36"]
  description = "WE Squid Prod backend members"
}

variable "ne_squid_prod_backend_ips" {
  type    = list(string)
  default = ["10.200.12.35", "10.200.12.36"]
  description = "NE Squid Prod backend members"
}

# ============================================================================
# BACKEND MEMBER CONFIGURATION - SQUID NON-PROD
# ============================================================================

variable "we_squid_nonprod_backend_ips" {
  type    = list(string)
  default = ["10.200.11.43", "10.200.11.44"]
  description = "WE Squid Non-Prod backend members"
}

variable "ne_squid_nonprod_backend_ips" {
  type    = list(string)
  default = ["10.200.12.43", "10.200.12.44"]
  description = "NE Squid Non-Prod backend members"
}

# ============================================================================
# BACKEND MEMBER CONFIGURATION - RDS WEB
# ============================================================================

variable "we_rds_backend_ips" {
  type    = list(string)
  default = ["10.200.11.68", "10.200.11.69"]
  description = "WE RDS Web backend members (RD Web Access servers)"
}

variable "ne_rds_backend_ips" {
  type    = list(string)
  default = ["10.200.12.68", "10.200.12.69"]
  description = "NE RDS Web backend members (RD Web Access servers)"
}

# ============================================================================
# FRONTEND IP CONFIGURATION - SQUID PROD
# ============================================================================

variable "we_squid_prod_frontend_ip" {
  type    = string
  default = "10.200.11.10"
  description = "WE Squid Prod frontend IP"
}

variable "ne_squid_prod_frontend_ip" {
  type    = string
  default = "10.200.12.10"
  description = "NE Squid Prod frontend IP"
}

# ============================================================================
# FRONTEND IP CONFIGURATION - SQUID NON-PROD
# ============================================================================

variable "we_squid_nonprod_frontend_ip" {
  type    = string
  default = "10.200.11.30"
  description = "WE Squid Non-Prod frontend IP"
}

variable "ne_squid_nonprod_frontend_ip" {
  type    = string
  default = "10.200.12.30"
  description = "NE Squid Non-Prod frontend IP"
}

# ============================================================================
# FRONTEND IP CONFIGURATION - RDS WEB
# ============================================================================

variable "we_rds_frontend_ip" {
  type    = string
  default = "10.200.11.80"
  description = "WE RDS Web frontend IP - CRITICAL for Premium FW DNAT"
}

variable "ne_rds_frontend_ip" {
  type    = string
  default = "10.200.12.80"
  description = "NE RDS Web frontend IP - CRITICAL for Premium FW DNAT"
}

# ============================================================================
# BACKEND PORT CONFIGURATION
# ============================================================================

variable "we_squid_prod_backend_port" {
  type    = number
  default = 3128
  description = "WE Squid Prod backend port"
}

variable "we_squid_nonprod_backend_port" {
  type    = number
  default = 3128
  description = "WE Squid Non-Prod backend port"
}

variable "ne_squid_prod_backend_port" {
  type    = number
  default = 3128
  description = "NE Squid Prod backend port"
}

variable "ne_squid_nonprod_backend_port" {
  type    = number
  default = 3128
  description = "NE Squid Non-Prod backend port"
}

variable "we_rds_backend_port" {
  type    = number
  default = 80
  description = "WE RDS Web backend port"
}

variable "ne_rds_backend_port" {
  type    = number
  default = 80
  description = "NE RDS Web backend port"
}

# ============================================================================
# HEALTH PROBE PATH CONFIGURATION
# ============================================================================

variable "we_squid_prod_health_probe_path" {
  type    = string
  default = "/"
  description = "WE Squid Prod health probe path"
}

variable "we_squid_nonprod_health_probe_path" {
  type    = string
  default = "/"
  description = "WE Squid Non-Prod health probe path"
}

variable "ne_squid_prod_health_probe_path" {
  type    = string
  default = "/"
  description = "NE Squid Prod health probe path"
}

variable "ne_squid_nonprod_health_probe_path" {
  type    = string
  default = "/"
  description = "NE Squid Non-Prod health probe path"
}

variable "we_rds_health_probe_path" {
  type    = string
  default = "/"
  description = "WE RDS Web health probe path"
}

variable "ne_rds_health_probe_path" {
  type    = string
  default = "/"
  description = "NE RDS Web health probe path"
}

# ============================================================================
# LOAD BALANCER COMMON CONFIGURATION
# ============================================================================

variable "lb_sku" {
  type    = string
  default = "Standard"
  description = "Load Balancer SKU (Standard or Basic)"
}

variable "lb_idle_timeout" {
  type    = number
  default = 30
  description = "Idle timeout in minutes"
}

variable "health_probe_protocol" {
  type    = string
  default = "HTTP"
  description = "Health probe protocol (HTTP or TCP)"
}

# ============================================================================
# TAGGING CONFIGURATION
# ============================================================================

variable "common_tags" {
  type = map(string)
  default = {
    ManagedBy = "Terraform"
    Deployed  = "2026-04-14"
    CostCenter = "HSBC-DMZ"
  }
  description = "Common tags applied to all resources"
}




