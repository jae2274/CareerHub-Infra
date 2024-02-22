data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ec2_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
      # "ecr:GetAuthorizationToken",
      # "ecr:BatchCheckLayerAvailability",
      # "ecr:GetDownloadUrlForLayer",
      # "ecr:GetRepositoryPolicy",
      # "ecr:DescribeRepositories",
      # "ecr:ListImages",
      # "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }

  # statement {
  #   effect    = "Allow"
  #   actions   = ["ssm:UpdateInstanceInformation", "ssmmessages:CreateControlChannel", "ssm:ListInstanceAssociations"]
  #   resources = ["*"] #TODO: restrict to the instances, maybe master arn:aws:ec2:ap-south-1:986069063944:instance/i-04dd9c7c5d11afe26
  # }

  # statement {
  #   effect    = "Allow"
  #   actions   = ["ec2messages:GetMessages", "ssm:ListAssociations"]
  #   resources = ["*"] #TODO: restrict to the resource, arn:aws:ssm:ap-south-1:986069063944:*
  # }
}


data "aws_iam_policy_document" "assume_role_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "k8s_node_role" {
  name               = "${var.cluster_name}-k8s_node-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "ec2_role_policy" {
  role   = aws_iam_role.k8s_node_role.name
  policy = data.aws_iam_policy_document.ec2_policy_doc.json
}

resource "aws_iam_role_policy" "secrets_manager_policy" {
  role   = aws_iam_role.k8s_node_role.name
  policy = data.aws_iam_policy_document.cert_secret_policy_doc.json
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.cluster_name}-k8s_node-profile"
  role = aws_iam_role.k8s_node_role.name
}
