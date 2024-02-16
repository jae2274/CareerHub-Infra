data "external" "helm_charts" {
  program = ["bash", "${path.module}/data_external/helm_charts.sh", "helm"]
}


resource "local_file" "value_yaml" {

  for_each = toset(split(",", data.external.helm_charts.result.list))

  filename = "${path.module}/${each.key}values.yaml"
  content = templatefile("${path.module}/helm/values_template.yaml", {
    logapi_image     = local.logapi_ecr
    logapi_mongo_uri = local.log_mongodb_endpoint
  })
}
