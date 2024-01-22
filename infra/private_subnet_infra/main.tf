locals {
  key = toset(keys(var.private_subnets))
}



resource "aws_subnet" "aws_private_subnets" {
  for_each = var.private_subnets

  vpc_id            = var.vpc_id
  availability_zone = each.value.az

  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = false

  tags = { Name = "${var.subnet_prefix_name}-${each.key}-private-subnet" }
}

resource "aws_route_table" "private_route_table" {
  for_each = var.private_subnets

  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = each.value.nat_gateway_id
  }

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each = aws_subnet.aws_private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

output "private_subnets" {
  value = aws_subnet.aws_private_subnets
}
