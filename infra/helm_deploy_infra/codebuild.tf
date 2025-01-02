
// start define log/cache bucket

resource "aws_s3_bucket" "codebuild_log_bucket" {
  bucket        = replace("${var.deploy_name}-cb", "_", "-")
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "codebuild_log_bucket" {
  bucket = aws_s3_bucket.codebuild_log_bucket.id

  rule {
    id     = "expiration"
    status = "Enabled"

    expiration {
      days = 3
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


locals {
  region     = data.aws_region.current.name
  ecr_domain = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

// end define log bucket
resource "aws_codebuild_project" "codebuild_project" {
  name          = "${var.deploy_name}-codebuild"
  description   = "CodeBuild for ${var.deploy_name}"
  build_timeout = 30
  service_role  = var.cd_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    image_pull_credentials_type = "CODEBUILD"
    type                        = "ARM_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.deploy_name}-lg"
      stream_name = "${var.deploy_name}-ls"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codebuild_log_bucket.id}/build-log"
    }
  }

  source {
    type = "NO_SOURCE"
    buildspec = templatefile("${path.module}/buildspec_template.yml", {
      region = local.region

      ecr_repo_name = var.ecr_repo_name
      ecr_domain    = local.ecr_domain

      namespace    = var.namespace
      release_name = replace(var.deploy_name, "_", "-")
      chart_repo   = var.chart_repo

      deploy_name           = var.deploy_name
      helm_value_secret_ids = var.helm_value_secret_ids
      helm_values           = var.helm_values
      eks_cluster_name      = var.eks_cluster_name
    })
  }

  vpc_config {
    vpc_id = var.vpc_id

    subnets = var.subnet_ids

    security_group_ids = [
      aws_security_group.codebuild_sg.id,
    ]
  }

}

resource "aws_security_group" "codebuild_sg" {
  name        = "${var.deploy_name}-codebuild-sg"
  description = "Security group for codebuild"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.codebuild_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
