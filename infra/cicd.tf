
module "cicd_infra" {
  source = "./cicd_infra"

  cicd_name = "${local.prefix_service_name}-dataprovider"

  repository_path = "jae2274/Careerhub-dataProvider"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = local.subnet_ids
  subnet_arns     = local.subnet_arns
}

