output "resource_group_name" {
  description = "Resource group name"
  value       = local.rg_name
}

output "app_public_ip" {
  description = "Public IP of the application server"
  value       = azurerm_public_ip.app.ip_address
}

output "app_private_ip" {
  description = "Private IP of the application server"
  value       = azurerm_network_interface.app.private_ip_address
}

output "db_public_ip" {
  description = "Public IP of the database server"
  value       = azurerm_public_ip.db.ip_address
}

output "db_private_ip" {
  description = "Private IP of the database server (used by the app to reach MySQL)"
  value       = azurerm_network_interface.db.private_ip_address
}

output "admin_username" {
  description = "Admin username for SSH/Ansible"
  value       = var.admin_username
}
