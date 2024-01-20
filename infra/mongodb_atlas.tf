


module "mongodb_atlas" {
  source = "./mongodb_atlas"

  mongodb_region = var.region
  project_name   = "${local.prefix}${local.service_name}-project"

  admin_db_user = {
    username = var.admin_db_username
    password = var.admin_db_password
  }

  atlas_key = {
    public_key  = var.atlas_public_key
    private_key = var.atlas_private_key
  }

  serverless_databases = [
    "${local.prefix}${local.service_name}-jobposting",
    "${local.prefix}${local.service_name}-log",
  ]

  vpc_id     = module.vpc_infra.vpc.id
  subnet_ids = [for subnet in module.vpc_infra.public_subnets : subnet.id]
  tags = {
    env = local.env
  }
}

# resource "aws_security_group" "mongodb_security_group" {

# }


