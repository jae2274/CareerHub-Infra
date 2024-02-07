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
