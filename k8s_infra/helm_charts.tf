

locals {
  charts = {
    log_api = {
      name     = "log-api"
      db_name  = "logs"
      api_port = 8080
    }

    data_processor = {
      name    = "data-processor"
      db_name = "careerhub"
      provider = {
        name      = "provider-grpc"
        grpc_port = 50051
      }
      scanner = {
        name      = "scanner-grpc"
        grpc_port = 50052
      }
      rest_api = {
        name      = "rest-api"
        api_port  = 8080
        node_port = local.node_port
      }
    }

    data_provider = {
      name  = "data-provider"
      sites = ["jumpit", "wanted"]
    }

    skill_scanner = {
      name = "skill-scanner"
    }
  }
}

data "external" "helm_charts" {
  program = ["bash", "${path.module}/data_external/helm_charts.sh", "helm_charts"]
}

locals {
  chart_list = split(",", data.external.helm_charts.result.list)
}

resource "local_file" "value_yaml" {

  for_each = toset(local.chart_list)

  filename = "${path.module}/${each.key}values.yaml"
  content = templatefile("${path.module}/${each.key}values_template.yaml", {
    charts = local.charts
  })
}



module "cd_infra" {
  source = "./helm_repo_infra"

  for_each = toset(local.chart_list)

  helm_path = "${path.module}/${each.key}"
}

module "log_api_helm_deploy" {
  source = "./helm_deploy_infra"


  deploy_name          = "${local.prefix_service_name}-log-api-helm"
  chart_repo           = module.cd_infra["helm_charts/logApi/"].chart_repo
  kubeconfig_secret_id = local.kubeconfig_secret_id
  ecr_repo_name        = local.logapi_ecr_name
  vpc_id               = local.vpc_id
  subnet_ids           = local.private_subnet_ids

  helm_value_secret_ids = {
    "mongoUri"   = local.log_mongodb_endpoint_secret_id
    "dbUsername" = local.mongodb_username_secret_id
    "dbPassword" = local.mongodb_password_secret_id
  }
}

module "careerhub_processor_helm_deploy" {
  source = "./helm_deploy_infra"


  deploy_name          = "${local.prefix_service_name}-processor-helm"
  chart_repo           = module.cd_infra["helm_charts/careerhub_processor/"].chart_repo
  kubeconfig_secret_id = local.kubeconfig_secret_id
  ecr_repo_name        = local.dataprocessor_ecr_name
  vpc_id               = local.vpc_id
  subnet_ids           = local.private_subnet_ids

  helm_value_secret_ids = {
    "mongoUri"   = local.jobposting_mongodb_endpoint_secret_id
    "dbUsername" = local.mongodb_username_secret_id
    "dbPassword" = local.mongodb_password_secret_id
  }
}

module "careerhub_provider_helm_deploy" {
  source = "./helm_deploy_infra"

  deploy_name          = "${local.prefix_service_name}-provider-helm"
  chart_repo           = module.cd_infra["helm_charts/careerhub_provider/"].chart_repo
  kubeconfig_secret_id = local.kubeconfig_secret_id
  ecr_repo_name        = local.dataprovider_ecr_name
  vpc_id               = local.vpc_id
  subnet_ids           = local.private_subnet_ids

  helm_value_secret_ids = {}
}

module "careerhub_skillscanner_helm_deploy" {
  source = "./helm_deploy_infra"

  deploy_name          = "${local.prefix_service_name}-skillscanner-helm"
  chart_repo           = module.cd_infra["helm_charts/careerhub_skillscanner/"].chart_repo
  ecr_repo_name        = local.skillscanner_ecr_name
  kubeconfig_secret_id = local.kubeconfig_secret_id

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids

  helm_value_secret_ids = {}
}
