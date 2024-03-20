locals {
  other_latest_tag = "build-date-tag"
}
module "dataprovider_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix_service_name}-provider"
  build_arch       = "arm64"

  repository_path = "jae2274/Careerhub-dataProvider"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}

module "dataprocessor_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix_service_name}-processor"
  build_arch       = "arm64"

  repository_path = "jae2274/Careerhub-dataProcessor"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}

module "logapi_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix_service_name}-logapi"
  build_arch       = "arm64"

  repository_path = "jae2274/LogApi"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}

module "skillscanner_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix_service_name}-skillscanner"
  build_arch       = "arm64"

  repository_path = "jae2274/Careerhub-SkillScanner"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}


module "user_service_cicd" {
  source = "./backend_cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix_service_name}-userservice"
  build_arch       = "arm64"

  repository_path = "jae2274/userService"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}

locals {
  dataprovider_ecr = {
    region = module.dataprovider_cicd.ecr_region
    domain = module.dataprovider_cicd.ecr_domain
  }
  dataprocessor_ecr = {
    region = module.dataprocessor_cicd.ecr_region
    domain = module.dataprocessor_cicd.ecr_domain
  }


  dataprovider_ecr_name  = module.dataprovider_cicd.ecr_name
  dataprocessor_ecr_name = module.dataprocessor_cicd.ecr_name
  skillscanner_ecr_name  = module.skillscanner_cicd.ecr_name
  logapi_ecr_name        = module.logapi_cicd.ecr_name
  user_service_ecr_name  = module.user_service_cicd.ecr_name
}

