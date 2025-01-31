locals {
  jobposting_db = "${local.prefix_service_name}-jobposting"
  userinfo_db   = "${local.prefix_service_name}-userinfo"
  review_db     = "${local.prefix_service_name}-review"
}

module "mongodb_atlas" {
  source = "./mongodb_atlas"

  mongodb_region = var.region
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
    env = var.env
  }
}

resource "aws_secretsmanager_secret" "username_secret" {
  name                    = "${local.prefix_service_name}-mongo-username"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "username_secret" {
  secret_id     = aws_secretsmanager_secret.username_secret.id
  secret_string = var.admin_db_username
}

resource "aws_secretsmanager_secret" "password_secret" {
  name                    = "${local.prefix_service_name}-mongo-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "password_secret" {
  secret_id     = aws_secretsmanager_secret.password_secret.id
  secret_string = var.admin_db_password
}
