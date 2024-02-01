locals {
  other_latest_tag = "build-date-tag"
}
module "dataprovider_cicd" {
  source = "./cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix_service_name}-provider"

  repository_path = "jae2274/Careerhub-dataProvider"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}

module "dataprocessor_cicd" {
  source = "./cicd_infra"

  other_latest_tag = local.other_latest_tag
  cicd_name        = "${local.prefix_service_name}-processor"

  repository_path = "jae2274/Careerhub-dataProcessor"
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
}
