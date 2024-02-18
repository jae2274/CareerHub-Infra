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

locals {
  jobposting_db = "${local.prefix_service_name}-jobposting"
  log_db        = "${local.prefix_service_name}-log"
}

module "mongodb_atlas" {
  source = "./mongodb_atlas"

  mongodb_region = var.region
  project_name   = "${local.prefix_service_name}-project"
  access_ip_list = concat(local.worker_ips, formatlist(local.master_ip))

  admin_db_user = {
    username = var.admin_db_username
    password = var.admin_db_password
  }

  atlas_key = {
    public_key  = var.atlas_public_key
    private_key = var.atlas_private_key
  }

  serverless_databases = [local.jobposting_db, local.log_db]

  tags = {
    env = local.env
  }
}




