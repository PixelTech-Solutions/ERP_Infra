variable "environment" {
  type        = string
  description = "Deployment environment (dev, prod)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "project_name" {
  type        = string
  description = "Project name used in resource naming"
  default     = "erp"
}

variable "resource_group_name" {
  type        = string
  description = "Existing resource group name. If empty, a new RG is created"
  default     = ""
}

variable "app_vm_size" {
  type        = string
  description = "Azure VM size for the application server (Java backend + React/nginx)"
  default     = "Standard_B1s"
}

variable "db_vm_size" {
  type        = string
  description = "Azure VM size for the MySQL database server"
  default     = "Standard_B1s"
}

variable "admin_username" {
  type        = string
  description = "Admin username for both VMs"
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "Admin password for both VMs (supplied via TF_VAR_admin_password secret)"
  sensitive   = true
}
