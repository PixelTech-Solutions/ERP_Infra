# -----------------------------------------------------------------------------
# Security group — Database tier: MySQL 3306 only from inside the VPC, SSH
# -----------------------------------------------------------------------------
resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "ERP MySQL database server access"
  vpc_id      = data.aws_vpc.default.id
  tags        = merge(local.common_tags, { Role = "db" })

  ingress {
    description = "MySQL from within the VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
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
# Database EC2 instance (dedicated MySQL host)
# -----------------------------------------------------------------------------
resource "aws_instance" "db" {
  ami                         = var.ami_id
  instance_type               = var.db_instance_type
  subnet_id                   = data.aws_subnet.default.id
  availability_zone           = var.availability_zone
  vpc_security_group_ids      = [aws_security_group.db.id]
  associate_public_ip_address = true
  tags                        = merge(local.common_tags, { Name = "ec2-${local.name_prefix}-db", Role = "db" })

  user_data = <<-EOF
    #!/bin/bash
    set -e
    echo "${var.admin_username}:${var.admin_password}" | chpasswd
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart ssh || systemctl restart sshd
    echo "db server ready" > /tmp/ready.txt
  EOF
}
