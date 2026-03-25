variable "environment" {
  type    = string
  default = "production"
}

variable "primary_subscription_id" {
  type      = string
  sensitive = true
}

variable "secondary_subscription_id" {
  type      = string
  sensitive = true
}

variable "we_resource_group_name" {
  type    = string
  default = "MIP-SI-WE-RG"
}

variable "ne_resource_group_name" {
  type    = string
  default = "MIP-SI-NE-RG"
}

variable "appgw_autoscale_min" {
  type    = number
  default = 1
}

variable "appgw_autoscale_max" {
  type    = number
  default = 10
}

variable "waf_mode" {
  type    = string
  default = "Prevention"
}

locals {
  default_tags = {
    Project     = "HSBC"
    Environment = var.environment
    Namespace   = "MIP-SI"
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }
}

