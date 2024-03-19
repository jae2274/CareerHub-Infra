locals {
  helm_infra_outputs = data.terraform_remote_state.helm_infra.outputs

  log_api_helm_chart_repo                = local.helm_infra_outputs.log_api_helm_chart_repo
  careerhub_processor_helm_chart_repo    = local.helm_infra_outputs.careerhub_processor_helm_chart_repo
  careerhub_provider_helm_chart_repo     = local.helm_infra_outputs.careerhub_provider_helm_chart_repo
  careerhub_skillscanner_helm_chart_repo = local.helm_infra_outputs.careerhub_skillscanner_helm_chart_repo
  node_port                              = local.helm_infra_outputs.node_port
}


module "log_api_helm_deploy" {
  source = "./helm_deploy_infra"


  deploy_name          = "${local.prefix_service_name}-log-api-helm"
  chart_repo           = local.log_api_helm_chart_repo
  kubeconfig_secret_id = local.kubeconfig_secret_id
  ecr_repo_name        = local.logapi_ecr_name
  vpc_id               = local.vpc_id
  subnet_ids           = [for subnet in local.private_subnets : subnet.id]

  helm_value_secret_ids = {
    "mongoUri"   = local.log_mongodb_endpoint_secret_id
    "dbUsername" = local.mongodb_username_secret_id
    "dbPassword" = local.mongodb_password_secret_id
  }
}

module "careerhub_processor_helm_deploy" {
  source = "./helm_deploy_infra"


  deploy_name          = "${local.prefix_service_name}-processor-helm"
  chart_repo           = local.careerhub_processor_helm_chart_repo
  kubeconfig_secret_id = local.kubeconfig_secret_id
  ecr_repo_name        = local.dataprocessor_ecr_name
  vpc_id               = local.vpc_id
  subnet_ids           = [for subnet in local.private_subnets : subnet.id]

  helm_value_secret_ids = {
    "mongoUri"   = local.jobposting_mongodb_endpoint_secret_id
    "dbUsername" = local.mongodb_username_secret_id
    "dbPassword" = local.mongodb_password_secret_id
  }
}

module "careerhub_provider_helm_deploy" {
  source = "./helm_deploy_infra"

  deploy_name          = "${local.prefix_service_name}-provider-helm"
  chart_repo           = local.careerhub_provider_helm_chart_repo
  kubeconfig_secret_id = local.kubeconfig_secret_id
  ecr_repo_name        = local.dataprovider_ecr_name
  vpc_id               = local.vpc_id
  subnet_ids           = [for subnet in local.private_subnets : subnet.id]

  helm_value_secret_ids = {}
}

module "careerhub_skillscanner_helm_deploy" {
  source = "./helm_deploy_infra"

  deploy_name          = "${local.prefix_service_name}-skillscanner-helm"
  chart_repo           = local.careerhub_skillscanner_helm_chart_repo
  ecr_repo_name        = local.skillscanner_ecr_name
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id     = local.vpc_id
  subnet_ids = [for subnet in local.private_subnets : subnet.id]

  helm_value_secret_ids = {}
}
