

provider "mongodbatlas" {
  public_key  = var.atlas_key.public_key
  private_key = var.atlas_key.private_key
}

resource "aws_security_group" "mongodb_security_group" {
  name        = "mongodb_security_group"
  description = "mongodb_security_group"
  vpc_id      = module.vpc_infra.vpc.id

  ingress {
    description = "mongodb ingress"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [module.vpc_infra.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


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

  vpc_id        = module.vpc_infra.vpc.id
  subnet_ids    = [for subnet in module.vpc_infra.public_subnets : subnet.id]
  mongodb_sg_id = aws_security_group.mongodb_security_group.id
  tags = {
    env = local.env
  }
}

# resource "aws_security_group" "mongodb_security_group" {

# }


