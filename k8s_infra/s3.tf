locals {
  service_name        = "careerhub"
  prefix_service_name = "${local.prefix}${local.service_name}"
}

resource "aws_s3_bucket" "helm_charts_bucket" {
  bucket = "${local.prefix_service_name}-helm-charts"
}

data "archive_file" "logapi_chart" {
  type        = "zip"
  output_path = "logapi_chart.zip"

  source_dir = "${path.module}/helm/logApi/"
}

resource "aws_s3_object" "logapi_chart" {
  bucket = aws_s3_bucket.helm_charts_bucket.id
  key    = data.archive_file.logapi_chart.output_path
  source = data.archive_file.logapi_chart.output_path

  etag = filemd5(data.archive_file.logapi_chart.output_path)
}


locals {
  value_yaml = templatefile("${path.module}/helm/values_template.yaml", {
    logapi_image = local.logapi_ecr,
    logapi_tag   = "latest",
    mongo_uri    = local.log_mongodb_endpoint
  })
}
resource "aws_s3_object" "value_yaml" {

  bucket  = aws_s3_bucket.helm_charts_bucket.id
  key     = "values.yaml"
  content = local.value_yaml

  etag = md5(local.value_yaml)
}
