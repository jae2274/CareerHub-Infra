

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  public_subnet_key_1 = "public_subnet_1"
  public_subnet_key_2 = "public_subnet_2"
}

module "vpc_infra" {
  source = "./vpc_infra"

  vpc_name       = "${local.prefix_service_name}-vpc"
  vpc_cidr_block = "10.0.0.0/16"
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
  subnet_ids = [
    for subnet in module.vpc_infra.public_subnets : subnet.id
  ]
  subnet_arns = [
    for subnet in module.vpc_infra.public_subnets : subnet.arn
  ]
}


module "private_subnet_infra" {
  source = "./private_subnet_infra"

  subnet_prefix_name = local.prefix_service_name
  private_subnets = {
    "${local.public_subnet_key_1}" = {
      paired_public_subnet_id = module.vpc_infra.public_subnets[local.public_subnet_key_1].id
      cidr_block              = "10.1.1.0/24"
    }
  }
}
