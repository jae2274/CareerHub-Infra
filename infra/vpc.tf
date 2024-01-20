

data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc_infra" {
  source = "./vpc_infra"

  vpc_name       = "${local.prefix}${local.service_name}-vpc"
  vpc_cidr_block = "10.0.0.0/16"
  public_subnets = {
    "public_subnet_1" = {
      public_cidr_block = "10.0.1.0/24"
      az                = data.aws_availability_zones.available.names[0]
    }
    "public_subnet_2" = {
      public_cidr_block = "10.0.2.0/24"
      az                = data.aws_availability_zones.available.names[1]
    }
  }
}



