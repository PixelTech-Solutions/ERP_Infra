# Use the account's default VPC and the default subnet in the chosen AZ.
# (The AWS IAM principal for this project has EC2 access only, so we reuse
#  existing default networking rather than creating new VPCs.)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.availability_zone
  default_for_az    = true
}
