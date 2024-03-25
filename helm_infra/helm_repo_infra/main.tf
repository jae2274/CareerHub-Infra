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
    "ecr_repo"      = aws_ecr_repository.helm_repo.id
    "chart_name"    = local.chart_name
    "chart_version" = local.chart_version
  }

  provisioner "local-exec" {
    command = "helm package ${var.helm_path}"
  }
}


resource "aws_ecr_repository" "helm_repo" {
  name = local.chart_name //TODO: 반드시! 환경별로 다른 이름을 사용 필요. 현재 구조로는 같은 이름만 사용 가능. 구조 변경 필요.


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

output "chart_repo" {
  value = aws_ecr_repository.helm_repo.repository_url
}
