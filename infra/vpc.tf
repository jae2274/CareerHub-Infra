data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  public_subnet_key_1 = "public_subnet_1"
  public_subnet_key_2 = "public_subnet_2"

  vpc_cidr_block = "10.0.0.0/16"
}

module "vpc_infra" {
  source = "./vpc_infra"

  vpc_name       = "${local.prefix_service_name}-vpc"
  vpc_cidr_block = local.vpc_cidr_block
  public_subnets = {
    "${local.public_subnet_key_1}" = {
      public_cidr_block = "10.0.1.0/24"
      az                = data.aws_availability_zones.available.names[0]
    }
    "${local.public_subnet_key_2}" = {
      public_cidr_block = "10.0.2.0/24"
      az                = data.aws_availability_zones.available.names[1]
    }
  }
}

locals {
  vpc_id = module.vpc_infra.vpc.id

  public_subnets = module.vpc_infra.public_subnets
}

resource "aws_eip" "nat_eips" {
  tags = {
    Name = "${local.prefix_service_name}-nat-eip"
  }
}

module "nat_instance" {
  source = "./nat_instance"

  instance_name    = "${local.prefix_service_name}-nat-gateway"
  allocation_id    = aws_eip.nat_eips.id
  public_subnet_id = module.vpc_infra.public_subnets[local.public_subnet_key_1].id
}


module "private_subnet_infra" {
  source = "./private_subnet_infra"

  vpc_id = local.vpc_id

  subnet_prefix_name = local.prefix_service_name

  private_subnets = {
    "${local.public_subnet_key_1}" = {
      nat_gateway_id = module.nat_instance.network_interface_id
      cidr_block     = "10.0.100.0/24"
      az             = module.vpc_infra.public_subnets[local.public_subnet_key_1].availability_zone
    }
  }
}

locals {
  private_subnets = module.private_subnet_infra.private_subnets
}
