output "app_public_ip" {
  description = "Public IP of the application server"
  value       = aws_instance.app.public_ip
}

output "app_private_ip" {
  description = "Private IP of the application server"
  value       = aws_instance.app.private_ip
}

output "db_public_ip" {
  description = "Public IP of the database server"
  value       = aws_instance.db.public_ip
}

output "db_private_ip" {
  description = "Private IP of the database server (used by the app to reach MySQL)"
  value       = aws_instance.db.private_ip
}

output "admin_username" {
  description = "OS user for SSH/Ansible"
  value       = var.admin_username
}
