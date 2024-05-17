locals {
  other_latest_tag = "build-date-tag"
}
module "careerhub_posting_provider_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}posting-provider"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-posting-provider"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_posting_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}posting-service"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-posting-service"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_posting_skillscanner_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}posting-skillscanner"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-posting-skillscanner"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}


module "user_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}userservice"
  build_arch       = "arm64"

  repository_path = "jae2274/userService"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_userinfo_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}userinfo-service"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-userinfo-service"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_api_composer_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}api-composer"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-api-composer"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_review_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}review-service"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-review-service"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

locals {
  careerhub_posting_provider_ecr = {
    region = module.careerhub_posting_provider_cicd.ecr_region
    domain = module.careerhub_posting_provider_cicd.ecr_domain
  }
  careerhub_posting_service_ecr = {
    region = module.careerhub_posting_service_cicd.ecr_region
    domain = module.careerhub_posting_service_cicd.ecr_domain
  }


  careerhub_posting_provider_ecr_name     = module.careerhub_posting_provider_cicd.ecr_name
  careerhub_posting_service_ecr_name      = module.careerhub_posting_service_cicd.ecr_name
  careerhub_posting_skillscanner_ecr_name = module.careerhub_posting_skillscanner_cicd.ecr_name

  careerhub_userinfo_service_ecr_name = module.careerhub_userinfo_service_cicd.ecr_name
  careerhub_api_composer_ecr_name     = module.careerhub_api_composer_cicd.ecr_name
  careerhub_review_service_ecr_name   = module.careerhub_review_service_cicd.ecr_name

  user_service_ecr_name = module.user_service_cicd.ecr_name
}

