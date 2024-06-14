locals {
  helm_infra_outputs = data.terraform_remote_state.helm_infra.outputs

  namespace                                      = local.helm_infra_outputs.namespace
  careerhub_posting_service_helm_chart_repo      = local.helm_infra_outputs.careerhub_posting_service_helm_chart_repo
  careerhub_posting_provider_helm_chart_repo     = local.helm_infra_outputs.careerhub_posting_provider_helm_chart_repo
  careerhub_posting_skillscanner_helm_chart_repo = local.helm_infra_outputs.careerhub_posting_skillscanner_helm_chart_repo
  careerhub_userinfo_service_helm_chart_repo     = local.helm_infra_outputs.careerhub_userinfo_service_helm_chart_repo
  careerhub_api_composer_helm_chart_repo         = local.helm_infra_outputs.careerhub_api_composer_helm_chart_repo
  careerhub_review_service_helm_chart_repo       = local.helm_infra_outputs.careerhub_review_service_helm_chart_repo
  careerhub_review_crawler_helm_chart_repo       = local.helm_infra_outputs.careerhub_review_crawler_helm_chart_repo

  log_system_helm_chart_repo = local.helm_infra_outputs.log_system_helm_chart_repo


  user_service_helm_chart_repo = local.helm_infra_outputs.user_service_helm_chart_repo
  careerhub_node_port          = local.helm_infra_outputs.careerhub_node_port
  user_service_node_port       = local.helm_infra_outputs.user_service_node_port

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

module "careerhub_posting_service_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name          = "${local.prefix_service_name}-careerhub-posting-service-helm"
  chart_repo           = local.careerhub_posting_service_helm_chart_repo
  kubeconfig_secret_id = local.kubeconfig_secret_id
  ecr_repo_name        = local.careerhub_posting_service_ecr_name
  vpc_id               = local.vpc_id
  subnet_ids           = local.private_subnet_ids
  subnet_arns          = local.private_subnet_arns

  helm_value_secret_ids = {
    "mongoUri"   = local.jobposting_mongodb_endpoint_secret_id
    "dbUsername" = local.mongodb_username_secret_id
    "dbPassword" = local.mongodb_password_secret_id
  }
}

module "careerhub_posting_provider_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name          = "${local.prefix_service_name}-careerhub-posting-provider-helm"
  chart_repo           = local.careerhub_posting_provider_helm_chart_repo
  kubeconfig_secret_id = local.kubeconfig_secret_id
  ecr_repo_name        = local.careerhub_posting_provider_ecr_name
  vpc_id               = local.vpc_id
  subnet_ids           = local.private_subnet_ids
  subnet_arns          = local.private_subnet_arns

  helm_value_secret_ids = {}
}

module "careerhub_posting_skillscanner_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name          = "${local.prefix_service_name}-careerhub-posting-skillscanner-helm"
  chart_repo           = local.careerhub_posting_skillscanner_helm_chart_repo
  ecr_repo_name        = local.careerhub_posting_skillscanner_ecr_name
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {}
}

module "careerhub_userinfo_service_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name          = "${local.prefix}careerhub-userinfo-service-helm"
  chart_repo           = local.careerhub_userinfo_service_helm_chart_repo
  ecr_repo_name        = local.careerhub_userinfo_service_ecr_name
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    "mongoUri"   = local.userinfo_mongodb_endpoint_secret_id
    "dbUsername" = local.mongodb_username_secret_id
  "dbPassword" = local.mongodb_password_secret_id }
}

module "careerhub_api_composer_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name          = "${local.prefix_service_name}-careerhub-api-composer-helm"
  chart_repo           = local.careerhub_api_composer_helm_chart_repo
  ecr_repo_name        = local.careerhub_api_composer_ecr_name
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    secretKey = local.jwt_secretkey_secret_id
  }
}

module "user_service_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name          = "${local.prefix_service_name}-userservice-helm"
  chart_repo           = local.user_service_helm_chart_repo
  ecr_repo_name        = local.user_service_ecr_name
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    dbHost             = local.user_mysql_endpoint_secret_id
    dbPort             = local.user_mysql_dbport_secret_id
    dbName             = local.user_mysql_dbname_secret_id
    dbUsername         = local.user_mysql_username_secret_id
    dbPassword         = local.user_mysql_password_secret_id
    googleClientId     = local.google_client_id_secret_id
    googleClientSecret = local.google_client_secret_secret_id
    googleRedirectUrl  = local.google_redirect_uri_secret_id
    secretKey          = local.jwt_secretkey_secret_id
  }
}

module "careerhub_review_service_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name          = "${local.prefix_service_name}-careerhub-review-service-helm"
  chart_repo           = local.careerhub_review_service_helm_chart_repo
  ecr_repo_name        = local.careerhub_review_service_ecr_name
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    "mongoUri"   = local.review_mongodb_endpoint_secret_id
    "dbUsername" = local.mongodb_username_secret_id
    "dbPassword" = local.mongodb_password_secret_id
  }
}
module "careerhub_review_crawler_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name          = "${local.prefix_service_name}-careerhub-review-crawler-helm"
  chart_repo           = local.careerhub_review_crawler_helm_chart_repo
  ecr_repo_name        = local.careerhub_review_crawler_ecr_name
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {}
}


resource "aws_secretsmanager_secret" "initial_admin_password" {
  name = "${local.prefix_service_name}-opensearch-password"

}

resource "aws_secretsmanager_secret_version" "initial_admin_password" {
  secret_id     = aws_secretsmanager_secret.initial_admin_password.id
  secret_string = var.initialAdminPassword
}

module "log_system_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name          = "${local.prefix_service_name}-log-system-helm"
  chart_repo           = local.log_system_helm_chart_repo
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    initialAdminPassword = aws_secretsmanager_secret.initial_admin_password.name
  }
}
