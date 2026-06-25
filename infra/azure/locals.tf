locals {
  name_prefix = "${var.project_name}-${var.environment}"
  rg_name     = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.this[0].name
  rg_location = var.resource_group_name != "" ? var.location : azurerm_resource_group.this[0].location

  vnet_cidr = "10.0.0.0/16"

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Stack       = "erp"
  }
}
