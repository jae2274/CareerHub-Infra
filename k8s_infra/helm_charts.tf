locals {
  charts = {
    log_api = {
      image     = local.logapi_ecr
      mongo_uri = local.log_mongodb_endpoint
    }
  }
}

data "external" "helm_charts" {
  program = ["bash", "${path.module}/data_external/helm_charts.sh", "helm"]
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
