data "aws_iam_policy_document" "cert_secret_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:PutSecretValue",
    ]
    resources = [aws_secretsmanager_secret.kubeconfig.arn]
  }
}


data "aws_iam_policy_document" "ecr_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = ["*"]
  }
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
  name               = "${var.cluster_name}-master-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "secrets_manager_policy" {
  role   = aws_iam_role.k8s_node_role.name
  policy = data.aws_iam_policy_document.cert_secret_policy_doc.json
}

resource "aws_iam_role_policy" "ec2_role_policy" {
  role   = aws_iam_role.k8s_node_role.name
  policy = data.aws_iam_policy_document.ecr_policy_doc.json
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.cluster_name}-master-profile"
  role = aws_iam_role.k8s_node_role.name
}
