provider "mongodbatlas" {
  public_key  = var.atlas_key.public_key
  private_key = var.atlas_key.private_key
}


resource "aws_security_group" "mongodb_security_group" {
  name        = "mongodb_security_group"
  description = "mongodb_security_group"
  vpc_id      = local.vpc_id

  ingress {
    description = "mongodb ingress"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
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
  userinfo_db   = "${local.prefix_service_name}-userinfo"
  review_db     = "${local.prefix_service_name}-review"
}

module "mongodb_atlas" {
  source = "./mongodb_atlas"

  mongodb_region = local.region
  project_name   = "${local.prefix_service_name}-project"

  admin_db_user = {
    username = var.admin_db_username
    password = var.admin_db_password
  }

  atlas_key = {
    public_key  = var.atlas_public_key
    private_key = var.atlas_private_key
  }

  serverless_databases = [local.jobposting_db, local.userinfo_db, local.review_db]

  tags = {
    env = local.env
  }
}

resource "aws_secretsmanager_secret" "jobposting_mongodb_endpoint" {
  name                           = "${local.prefix_service_name}-jobposting-mongodb-endpoint"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "jobposting_mongodb_endpoint" {
  secret_id     = aws_secretsmanager_secret.jobposting_mongodb_endpoint.id
  secret_string = module.mongodb_atlas.public_endpoint[local.jobposting_db]
}

resource "aws_secretsmanager_secret" "userinfo_mongodb_endpoint" {
  name                           = "${local.prefix_service_name}-userinfo-mongodb-endpoint"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "userinfo_mongodb_endpoint" {
  secret_id     = aws_secretsmanager_secret.userinfo_mongodb_endpoint.id
  secret_string = module.mongodb_atlas.public_endpoint[local.userinfo_db]
}

resource "aws_secretsmanager_secret" "review_mongodb_endpoint" {
  name                           = "${local.prefix_service_name}-review-mongodb-endpoint"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "review_mongodb_endpoint" {
  secret_id     = aws_secretsmanager_secret.review_mongodb_endpoint.id
  secret_string = module.mongodb_atlas.public_endpoint[local.review_db]
}

resource "aws_secretsmanager_secret" "username_secret" {
  name                           = "${local.prefix_service_name}-mongo-username"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "username_secret" {
  secret_id     = aws_secretsmanager_secret.username_secret.id
  secret_string = var.admin_db_username
}

resource "aws_secretsmanager_secret" "password_secret" {
  name                           = "${local.prefix_service_name}-mongo-password"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "password_secret" {
  secret_id     = aws_secretsmanager_secret.password_secret.id
  secret_string = var.admin_db_password
}

locals {
  jobposting_mongodb_endpoint_secret_id = aws_secretsmanager_secret.jobposting_mongodb_endpoint.name
  userinfo_mongodb_endpoint_secret_id   = aws_secretsmanager_secret.userinfo_mongodb_endpoint.name
  review_mongodb_endpoint_secret_id     = aws_secretsmanager_secret.review_mongodb_endpoint.name

  mongodb_username_secret_id = aws_secretsmanager_secret.username_secret.name
  mongodb_password_secret_id = aws_secretsmanager_secret.password_secret.name
}
