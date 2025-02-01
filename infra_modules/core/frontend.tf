locals {
  backend_root_path = "/api"
}

module "frontend_cicd" {
  source = "./frontend_cicd_infra"

  cicd_name  = "${local.prefix_service_name}-frontend"
  build_arch = "arm64"

  repository_path = "jae2274/Careerhub-Front"
  branch_name     = var.branch
  vpc_id          = var.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns

  build_env_vars = {
    "BACKEND_URL" = local.backend_root_path
  }
}

locals {
  frontend_website_endpoint = module.frontend_cicd.frontend_website_endpoint
}
