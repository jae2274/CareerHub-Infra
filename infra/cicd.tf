
module "cicd_infra" {
  source = "./cicd_infra"

  cicd_name = "${local.prefix_service_name}-dataprovider"

  repository_path = "jae2274/Careerhub-dataProvider"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]
}

locals {
  ecr_domain = module.cicd_infra.ecr_domain
}
