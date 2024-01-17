
#resource "aws_security_group" "mongodb_security_group" {
#
#}
#
#resource "aws_vpc_endpoint" "ptfe_service" {
#  vpc_id            = module.vpc_infra.vpc.id
#  service_name      = module.mongodb_atlas.privatelink_endpoint_service_name
#  vpc_endpoint_type = "Interface"
#
#  security_group_ids = [
#    aws_security_group.ptfe_service.id,
#  ]
#
#  subnet_ids          = [module.vpc_infra.public_subnet_ids["set1"].id]
#  private_dns_enabled = false
#}

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

module "eks_playground" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = "${local.prefix}${local.service_name}-eks"
  cluster_version = "1.28"
  vpc_id          = module.vpc_infra.vpc.id
  subnet_ids      = [for subnet in module.vpc_infra.public_subnet_ids : subnet.id]


  eks_managed_node_groups = {
    default_node_group = {
      min_size       = 2
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3a.medium"]
      capacity_type  = "SPOT"
    }
  }
}

# module "mongodb_atlas" {
#   source = "./mongodb_atlas"

#   atlas_key = {
#     public_key  = var.atlas_key.public_key
#     private_key = var.atlas_key.private_key
#   }

#   mongodb_region = var.region
#   project_name   = "${local.prefix}${local.service_name}-project"

#   admin_db_user = {
#     username = var.admin_db_user.username
#     password = var.admin_db_user.password
#   }

#   serverless_databases = [
#     "${local.prefix}${local.service_name}-db"
#   ]

#   tags = {
#     env = local.env
#   }
# }
