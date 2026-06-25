variable "environment" {
  type        = string
  description = "Deployment environment (dev, prod)"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "Project name used in resource naming"
  default     = "erp"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "availability_zone" {
  type        = string
  description = "AWS availability zone (must support the chosen instance types)"
  default     = "us-east-1a"
}

variable "app_instance_type" {
  type        = string
  description = "EC2 instance type for the application server"
  default     = "t3.micro"
}

variable "db_instance_type" {
  type        = string
  description = "EC2 instance type for the MySQL database server"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "Ubuntu 22.04 AMI ID for the chosen region"
}

variable "admin_username" {
  type        = string
  description = "OS user that Ansible connects as (Ubuntu AMIs use 'ubuntu')"
  default     = "ubuntu"
}

variable "admin_password" {
  type        = string
  description = "Password set for the admin user so Ansible can SSH (via TF_VAR_admin_password secret)"
  sensitive   = true
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed SSH access (defaults to anywhere for the CI runner)"
  default     = ["0.0.0.0/0"]
}
