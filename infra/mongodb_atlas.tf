# module "mongodb_atlas" {
#   source = "./mongodb_atlas"

#   atlas_key = {
#     public_key  = var.atlas_public_key
#     private_key = var.atlas_private_key
#   }

#   mongodb_region = var.region
#   project_name   = "${local.prefix}${local.service_name}-project"

#   admin_db_user = {
#     username = var.admin_db_username
#     password = var.admin_db_password
#   }

#   serverless_databases = [
#     "${local.prefix}${local.service_name}-db"
#   ]

#   tags = {
#     env = local.env
#   }
# }
