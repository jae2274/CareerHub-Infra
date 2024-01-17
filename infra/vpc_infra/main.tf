resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.tags, { Name = var.vpc_name })
}


resource "aws_subnet" "aws_public_subnets" {
  for_each = var.pair_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.public_cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "${var.vpc_name}-${each.key}-public-subnet" })
}

resource "aws_subnet" "aws_private_subnets" {
  for_each = var.pair_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.private_cidr_block
  availability_zone = each.value.az

  tags = merge(var.tags, { Name = "${var.vpc_name}-${each.key}-private-subnet" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, { Name = "${var.vpc_name}-igw" })
}

resource "aws_eip" "eips" {
  for_each = aws_subnet.aws_public_subnets
  vpc      = true

  tags = merge(var.tags, { Name = "${var.vpc_name}-${each.key}-nat-eip" })
}

resource "aws_nat_gateway" "nat_gws" {
  for_each = aws_subnet.aws_public_subnets

  subnet_id     = each.value.id
  allocation_id = aws_eip.eips[each.key].id

  tags = merge(var.tags, { Name = "${var.vpc_name}-${each.key}-nat-gw" })
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }

  tags = merge(var.tags, { Name = "${var.vpc_name}-${var.vpc_name}-public-route-table" })
}

resource "aws_route_table" "private_route_tables" {
  for_each = aws_nat_gateway.nat_gws

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = each.value.id
  }

  route {
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }

  tags = merge(var.tags, { Name = "${var.vpc_name}-${each.key}-private-route-table" })
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each = aws_subnet.aws_public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each = aws_subnet.aws_private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_tables[each.key].id
}

output "public_subnets" {
  value = aws_subnet.aws_public_subnets
}

output "private_subnets" {
  value = aws_subnet.aws_private_subnets
}