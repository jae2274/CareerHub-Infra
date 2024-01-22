data "aws_subnet" "public_subnets" {
  for_each = var.private_subnets

  id = each.value.paired_public_subnet_id
}

resource "aws_subnet" "aws_private_subnets" {
  for_each = data.aws_subnet.public_subnets

  vpc_id            = each.value.vpc_id
  availability_zone = each.value.availability_zone

  cidr_block              = var.private_subnets[each.key].cidr_block
  map_public_ip_on_launch = false

  tags = { Name = "${var.subnet_prefix_name}-${each.key}-private-subnet" }
}

output "private_subnets" {
  value = aws_subnet.aws_private_subnets
}
