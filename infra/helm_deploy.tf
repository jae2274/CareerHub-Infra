locals {
  helm_infra_outputs = data.terraform_remote_state.helm_infra.outputs

  log_api_helm_chart_repo                = local.helm_infra_outputs.log_api_helm_chart_repo
  careerhub_processor_helm_chart_repo    = local.helm_infra_outputs.careerhub_processor_helm_chart_repo
  careerhub_provider_helm_chart_repo     = local.helm_infra_outputs.careerhub_provider_helm_chart_repo
  careerhub_skillscanner_helm_chart_repo = local.helm_infra_outputs.careerhub_skillscanner_helm_chart_repo
  user_service_helm_chart_repo           = local.helm_infra_outputs.user_service_helm_chart_repo
  careerhub_node_port                    = local.helm_infra_outputs.careerhub_node_port
  user_service_node_port                 = local.helm_infra_outputs.user_service_node_port
}

resource "aws_secretsmanager_secret" "jwt_secretkey" {
  name = "${local.prefix_service_name}-jwt-secretkey"
}

resource "aws_secretsmanager_secret_version" "jwt_secretkey" {
  secret_id     = aws_secretsmanager_secret.jwt_secretkey.id
  secret_string = var.jwt_secretkey
}

locals {
  jwt_secretkey_secret_id = aws_secretsmanager_secret.jwt_secretkey.id
}

module "log_api_helm_deploy" {
  source = "./helm_deploy_infra"


  deploy_name          = "${local.prefix_service_name}-log-api-helm"
  chart_repo           = local.log_api_helm_chart_repo
  kubeconfig_secret_id = local.kubeconfig_secret_id
  ecr_repo_name        = local.logapi_ecr_name
  vpc_id               = local.vpc_id
  subnet_ids           = local.private_subnet_ids
  subnet_arns          = local.private_subnet_arns

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
  subnet_ids           = local.private_subnet_ids
  subnet_arns          = local.private_subnet_arns

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
  subnet_ids           = local.private_subnet_ids
  subnet_arns          = local.private_subnet_arns

  helm_value_secret_ids = {}
}

module "careerhub_skillscanner_helm_deploy" {
  source = "./helm_deploy_infra"

  deploy_name          = "${local.prefix_service_name}-skillscanner-helm"
  chart_repo           = local.careerhub_skillscanner_helm_chart_repo
  ecr_repo_name        = local.skillscanner_ecr_name
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {}
}

module "user_service_helm_deploy" {
  source = "./helm_deploy_infra"

  deploy_name          = "${local.prefix_service_name}-userservice-helm"
  chart_repo           = local.user_service_helm_chart_repo
  ecr_repo_name        = local.user_service_ecr_name
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    dbHost             = local.user_mysql_endpoint_secret_id
    dbName             = local.user_mysql_dbname_secret_id
    dbUsername         = local.user_mysql_username_secret_id
    dbPassword         = local.user_mysql_password_secret_id
    googleClientId     = local.google_client_id_secret_id
    googleClientSecret = local.google_client_secret_secret_id
    googleRedirectUrl  = local.google_redirect_uri_secret_id
    secretKey          = local.jwt_secretkey_secret_id
  }
}

# googleClientId: #known after the deployment
# googleClientSecret: #known after the deployment
# redirectUrl: #known after the deployment
# secretKey: #known after the deployment
