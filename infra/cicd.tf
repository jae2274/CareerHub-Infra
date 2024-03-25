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
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}

module "careerhub_posting_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}posting-service"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-posting-service"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}

module "logapi_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}logapi"
  build_arch       = "arm64"

  repository_path = "jae2274/LogApi"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}

module "careerhub_posting_skillscanner_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}posting-skillscanner"
  build_arch       = "arm64"

  repository_path = "jae2274/careerhub-posting-skillscanner"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}


module "user_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix}userservice"
  build_arch       = "arm64"

  repository_path = "jae2274/userService"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
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
  logapi_ecr_name                         = module.logapi_cicd.ecr_name
  user_service_ecr_name                   = module.user_service_cicd.ecr_name
}

