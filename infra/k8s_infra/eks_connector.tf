// start define iam role and policy
data "aws_iam_policy_document" "eks_connector_policy_doc" {
  statement {
    sid    = "SsmControlChannel"
    effect = "Allow"

    actions = [
      "ssmmessages:CreateControlChannel"
    ]

    resources = ["arn:aws:eks:*:*:cluster/*"]
  }

  statement {
    sid    = "SsmDataPlaneOperations"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenDataChannel",
      "ssmmessages:OpenControlChannel"
    ]
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "eks_connector_assume_role_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_connector_role" {
  name               = "${var.cluster_name}-eksconn-role"
  assume_role_policy = data.aws_iam_policy_document.eks_connector_assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "eks_connector_role_policy" {
  role   = aws_iam_role.eks_connector_role.name
  policy = data.aws_iam_policy_document.eks_connector_policy_doc.json

}
