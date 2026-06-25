# -----------------------------------------------------------------------------
# Security group — Application tier: HTTP/HTTPS, backend 8080, SSH
# -----------------------------------------------------------------------------
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "ERP application server access"
  vpc_id      = data.aws_vpc.default.id
  tags        = merge(local.common_tags, { Role = "app" })

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend API"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------------------------------------------------------
# Application EC2 instance
# -----------------------------------------------------------------------------
resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.app_instance_type
  subnet_id                   = data.aws_subnet.default.id
  availability_zone           = var.availability_zone
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true
  tags                        = merge(local.common_tags, { Name = "ec2-${local.name_prefix}-app", Role = "app" })

  # Enable SSH password auth so Ansible can connect with the admin password.
  user_data = <<-EOF
    #!/bin/bash
    set -e
    echo "${var.admin_username}:${var.admin_password}" | chpasswd
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart ssh || systemctl restart sshd
    echo "app server ready" > /tmp/ready.txt
  EOF
}
