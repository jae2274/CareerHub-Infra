provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

locals {
  jobposting_db = "${local.prefix_service_name}-jobposting"
  userinfo_db   = "${local.prefix_service_name}-userinfo"
  review_db     = "${local.prefix_service_name}-review"
}

module "mongodb_atlas" {
  source = "./mongodb_atlas"

  mongodb_region = local.network_output.region
  project_name   = "${local.prefix_service_name}-project"

  admin_db_user = {
    username = var.admin_db_username
    password = var.admin_db_password
  }

  serverless_databases = [local.jobposting_db, local.userinfo_db, local.review_db]

  tags = {
    env = local.env
  }
}
