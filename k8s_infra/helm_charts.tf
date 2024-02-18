data "aws_secretsmanager_secret_version" "mongodb_user" {
  secret_id = local.mongodb_user_secret_id
}

locals {
  mongodb_user = jsondecode(data.aws_secretsmanager_secret_version.mongodb_user.secret_string)
}

locals {
  charts = {
    log_api = {
      name      = "log-api"
      image     = local.logapi_ecr
      tag       = "latest" #TODO: Change this to dynamic
      mongo_uri = local.log_mongodb_endpoint
      api_port  = 8080
    }

    data_processor = {
      name      = "data-processor"
      image     = local.dataprocessor_ecr
      tag       = "latest" #TODO: Change this to dynamic
      mongo_uri = local.jobposting_mongodb_endpoint
      grpc_port = 50051
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
