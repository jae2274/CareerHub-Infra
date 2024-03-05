module "frontend_cicd" {
  source = "./frontend_cicd_infra"

  cicd_name  = "${local.prefix_service_name}-frontend"
  build_arch = "arm64"

  repository_path = "jae2274/Careerhub-Front"
  branch_name     = local.branch
  vpc_id          = local.vpc_id
  subnet_ids      = [for subnet in local.private_subnets : subnet.id]
  subnet_arns     = [for subnet in local.private_subnets : subnet.arn]

  build_env_vars = {
    "BACKEND_URL" = "/api" //TODO: change this to the backend url
  }

}
