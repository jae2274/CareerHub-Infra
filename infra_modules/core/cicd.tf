locals {
  other_latest_tag   = "build-date-tag"
  private_subnet_ids = [for k, subnet_id in var.private_subnet_ids : subnet_id]
}

data "aws_subnet" "private_subnets" {
  for_each = var.private_subnet_ids
  id       = each.value
}

locals {
  private_subnet_arns = [for subnet in data.aws_subnet.private_subnets : subnet.arn]
}

module "careerhub_posting_provider_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${var.prefix}posting-provider"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-posting-provider"
  branch_name     = var.branch
  vpc_id          = var.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_posting_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${var.prefix}posting-service"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-posting-service"
  branch_name     = var.branch
  vpc_id          = var.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_posting_skillscanner_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${var.prefix}posting-skillscanner"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-posting-skillscanner"
  branch_name     = var.branch
  vpc_id          = var.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}


module "auth_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${var.prefix}auth-service"
  build_arch       = "arm64"

  repository_path = "jae2274/auth-service"
  branch_name     = var.branch
  vpc_id          = var.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_userinfo_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${var.prefix}userinfo-service"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-userinfo-service"
  branch_name     = var.branch
  vpc_id          = var.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_api_composer_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${var.prefix}api-composer"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-api-composer"
  branch_name     = var.branch
  vpc_id          = var.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_review_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${var.prefix}review-service"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-review-service"
  branch_name     = var.branch
  vpc_id          = var.vpc_id
  subnet_ids      = local.private_subnet_ids
  subnet_arns     = local.private_subnet_arns
}

module "careerhub_review_crawler_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${var.prefix}review-crawler"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-review-crawler"
  branch_name     = var.branch
  vpc_id          = var.vpc_id
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
  careerhub_review_crawler_ecr_name   = module.careerhub_review_crawler_cicd.ecr_name

  auth_service_ecr_name = module.auth_service_cicd.ecr_name
}

