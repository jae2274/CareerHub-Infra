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
  access_ip_list = local.worker_ips

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

resource "aws_secretsmanager_secret" "log_mongodb_endpoint" {
  name = "${local.prefix_service_name}-log-mongodb-endpoint"
}

resource "aws_secretsmanager_secret_version" "log_mongodb_endpoint" {
  secret_id     = aws_secretsmanager_secret.log_mongodb_endpoint.id
  secret_string = module.mongodb_atlas.public_endpoint[local.log_db]
}

resource "aws_secretsmanager_secret" "jobposting_mongodb_endpoint" {
  name = "${local.prefix_service_name}-jobposting-mongodb-endpoint"
}

resource "aws_secretsmanager_secret_version" "jobposting_mongodb_endpoint" {
  secret_id     = aws_secretsmanager_secret.jobposting_mongodb_endpoint.id
  secret_string = module.mongodb_atlas.public_endpoint[local.jobposting_db]
}

resource "aws_secretsmanager_secret" "username_secret" {
  name = "${local.prefix_service_name}-mongo-username"
}

resource "aws_secretsmanager_secret_version" "username_secret" {
  secret_id     = aws_secretsmanager_secret.username_secret.id
  secret_string = var.admin_db_username
}

resource "aws_secretsmanager_secret" "password_secret" {
  name = "${local.prefix_service_name}-mongo-password"
}

resource "aws_secretsmanager_secret_version" "password_secret" {
  secret_id     = aws_secretsmanager_secret.password_secret.id
  secret_string = var.admin_db_password
}

locals {
  jobposting_mongodb_endpoint_secret_id = aws_secretsmanager_secret.jobposting_mongodb_endpoint.name
  log_mongodb_endpoint_secret_id        = aws_secretsmanager_secret.log_mongodb_endpoint.name
  mongodb_username_secret_id            = aws_secretsmanager_secret.username_secret.name
  mongodb_password_secret_id            = aws_secretsmanager_secret.password_secret.name
}
