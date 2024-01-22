// start define iam role and policy
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
  name               = "${var.cicd_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.codebuild_policy_doc.json
}
// end define iam role and policy


resource "aws_codebuild_project" "codebuild_project" {
  name          = "${var.cicd_name}-codebuild"
  description   = "CodeBuild for ${var.cicd_name}"
  build_timeout = 30
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.cicd_name}-lg"
      stream_name = "${var.cicd_name}-ls"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
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
  name        = "codebuild_sg"
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
