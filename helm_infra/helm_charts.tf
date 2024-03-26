

locals {
  careerhub_node_port    = 30000
  user_service_node_port = 30001
  charts = {
    log_api = {
      name     = "log-api"
      db_name  = "logs"
      api_port = 8080
    }

    data_processor = {
      name    = "posting-service"
      db_name = "careerhub"
      provider = {
        name      = "provider-grpc"
        grpc_port = 50051
      }
      scanner = {
        name      = "skillscanner-grpc"
        grpc_port = 50052
      }
      restapi = {
        name      = "restapi-grpc"
        grpc_port = 50053
      }
    }

    data_provider = {
      name  = "posting-provider"
      sites = ["jumpit", "wanted"]
    }

    skill_scanner = {
      name = "posting-skillscanner"
    }

    user_service = {
      name      = "user-service"
      api_port  = 8080
      node_port = local.user_service_node_port
    }

    api_composer = {
      name      = "api-composer"
      api_port  = 8080
      node_port = local.careerhub_node_port
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

  prefix    = local.prefix
  helm_path = "${path.module}/${each.key}"
}

output "careerhub_node_port" {
  value = local.careerhub_node_port
}

output "user_service_node_port" {
  value = local.user_service_node_port
}

output "log_api_helm_chart_repo" {
  value = module.cd_infra["helm_charts/logApi/"].chart_repo
}

output "careerhub_posting_service_helm_chart_repo" {
  value = module.cd_infra["helm_charts/careerhub_posting_service/"].chart_repo
}

output "careerhub_posting_provider_helm_chart_repo" {
  value = module.cd_infra["helm_charts/careerhub_posting_provider/"].chart_repo
}

output "careerhub_posting_skillscanner_helm_chart_repo" {
  value = module.cd_infra["helm_charts/careerhub_posting_skillscanner/"].chart_repo
}

output "user_service_helm_chart_repo" {
  value = module.cd_infra["helm_charts/user_service/"].chart_repo
}
