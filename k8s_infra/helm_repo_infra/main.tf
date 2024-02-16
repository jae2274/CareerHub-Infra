data "external" "chart_info" {
  program = ["bash", "${path.module}/external/chart_info.sh", var.helm_path]
}



locals {
  chart_name    = data.external.chart_info.result.chart_name
  chart_version = data.external.chart_info.result.chart_version
  chart_package = "${local.chart_name}-${local.chart_version}.tgz"
}


resource "null_resource" "chart_package" {
  triggers = {
    "chart_name"    = local.chart_name
    "chart_version" = local.chart_version
  }

  provisioner "local-exec" {
    command = "helm package ${var.helm_path}"
  }
}


resource "aws_ecr_repository" "helm_repo" {
  name = local.chart_name


  image_scanning_configuration {
    scan_on_push = true
  }
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


locals {
  region      = data.aws_region.current.name
  repo_domain = split("/", aws_ecr_repository.helm_repo.repository_url)[0]
}

resource "null_resource" "helm_push" {
  triggers = {
    "chart_package" = local.chart_package
  }


  depends_on = [
    aws_ecr_repository.helm_repo,
  ]

  provisioner "local-exec" {
    command = <<EOF
aws ecr get-login-password --region ${local.region} | helm registry login --username AWS --password-stdin ${local.repo_domain}
helm push ${local.chart_package} oci://${local.repo_domain}/

rm -f ${local.chart_package}
        EOF
  }
}
