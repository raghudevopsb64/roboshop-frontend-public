data "aws_subnets" "ngw" {
  filter {
    name   = "tag:NGW"
    values = ["true"]
  }
}

data "aws_vpc" "default" {
  id = var.DEFAULT_VPC_ID
}


