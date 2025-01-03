

locals {

  namespace = "careerhub"

  charts = {
    namespace = local.namespace
    log_system = {
      name            = "log-system"
      opensearch_name = "log-system-opensearch"
      dashboard_name  = "log-system-opensearch-dashboard"
      dashboard_port  = 8080
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
      name     = "auth-service"
      api_port = 8080
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
      name     = "api-composer"
      api_port = 8080
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
//helm_charts의 폴더내의 helm chart 목록을 가져오는 코드
data "external" "helm_charts" {
  program = ["bash", "${path.module}/data_external/helm_charts.sh", "helm_charts"]
}

locals { //가져온 helm chart 목록을 list로 변환
  chart_list = split(",", data.external.helm_charts.result.list)
}


module "cd_infra" {
  source = "./helm_repo_infra"

  for_each = toset(local.chart_list)

  prefix       = local.prefix
  helm_path    = "${path.module}/${each.key}"
  chart_values = local.charts
  env_value    = replace(local.env, "-", "_")
}

output "api_composer_service" {
  value = {
    name = local.charts.api_composer.name
    port = local.charts.api_composer.api_port
  }
}

output "auth_service" {
  value = {
    name = local.charts.auth_service.name
    port = local.charts.auth_service.api_port
  }
}

output "log_system" {
  value = {
    name = local.charts.log_system.dashboard_name
    port = local.charts.log_system.dashboard_port
  }
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
