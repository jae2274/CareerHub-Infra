

locals {
  careerhub_node_port    = 30000
  auth_service_node_port = 30001
  log_system_node_port   = 30002

  namespace = "careerhub"

  charts = {
    namespace = local.namespace
    log_system = {
      name = "log-system"
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
      suggester = {
        name      = "data-processor-suggester"
        grpc_port = 50054
      }
    }

    data_provider = {
      name  = "posting-provider"
      sites = ["jumpit", "wanted"]
    }

    skill_scanner = {
      name = "posting-skillscanner"
    }

    auth_service = {
      name      = "auth-service"
      api_port  = 8080
      node_port = local.auth_service_node_port
      mailer = {
        name      = "user-mailer-grpc"
        grpc_port = 50054
      }
    }

    userinfo_service = {
      name    = "userinfo-service"
      db_name = "userinfo"
      restapi = {
        name      = "userinfo-restapi-grpc"
        grpc_port = 50051
      }
      suggester = {
        name      = "userinfo-suggester-grpc"
        grpc_port = 50054
      }
    }

    api_composer = {
      name      = "api-composer"
      api_port  = 8080
      node_port = local.careerhub_node_port
    }

    review_service = {
      name    = "review-service"
      db_name = "review"
      restapi = {
        name      = "review-restapi-grpc"
        grpc_port = 50051
      }
      crawler = {
        name      = "review-crawler-grpc"
        grpc_port = 50052
      }
      provider = {
        name      = "review-provider-grpc"
        grpc_port = 50053
      }
    }
    review_crawler = {
      name = "review-crawler"
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

output "auth_service_node_port" {
  value = local.auth_service_node_port
}

output "namespace" {
  value = local.namespace
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

output "careerhub_userinfo_service_helm_chart_repo" {
  value = module.cd_infra["helm_charts/careerhub_userinfo_service/"].chart_repo
}

output "careerhub_api_composer_helm_chart_repo" {
  value = module.cd_infra["helm_charts/careerhub_api_composer/"].chart_repo
}

output "auth_service_helm_chart_repo" {
  value = module.cd_infra["helm_charts/auth_service/"].chart_repo
}

output "log_system_helm_chart_repo" {
  value = module.cd_infra["helm_charts/log_system/"].chart_repo
}

output "careerhub_review_service_helm_chart_repo" {
  value = module.cd_infra["helm_charts/careerhub_review_service/"].chart_repo
}

output "careerhub_review_crawler_helm_chart_repo" {
  value = module.cd_infra["helm_charts/careerhub_review_crawler/"].chart_repo
}
