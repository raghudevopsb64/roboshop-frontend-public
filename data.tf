data "aws_subnets" "ngw" {
  filter {
    name   = "tag:NGW"
    values = ["true"]
  }
}

data "aws_vpc" "default" {
  id = var.DEFAULT_VPC_ID
}

data "dns_a_record_set" "frontend" {
  host = "frontend-${var.ENV}.roboshop.internal"
}

output "dns" {
  value = data.dns_a_record_set.frontend
}
