

data "aws_iam_policy_document" "codebuild_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:*:*:network-interface/*"]

    condition {
      test     = "ArnEquals"
      variable = "ec2:Subnet"

      values = var.subnet_arns
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.codebuild_log_bucket.arn,
      "${aws_s3_bucket.codebuild_log_bucket.arn}/*",
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "codebuild_assume_role_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.deploy_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.codebuild_policy_doc.json
}
// end define iam role and policy

// start define log/cache bucket

resource "aws_s3_bucket" "codebuild_log_bucket" {
  bucket        = "${var.deploy_name}-codebuild-log"
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
  region = data.aws_region.current.name
  ecr = var.ecr_repo_name == "" ? { exists : false } : {
    exists    = true
    repo_name = var.ecr_repo_name
    domain    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
  }
}

// end define log bucket
resource "aws_codebuild_project" "codebuild_project" {
  name          = "${var.deploy_name}-codebuild"
  description   = "CodeBuild for ${var.deploy_name}"
  build_timeout = 30
  service_role  = aws_iam_role.codebuild_role.arn

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
      region                = local.region
      ecr                   = local.ecr
      helm_name             = var.deploy_name
      chart_repo            = var.chart_repo
      kubeconfig_secret_id  = var.kubeconfig_secret_id
      helm_value_secret_ids = var.helm_value_secret_ids
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
