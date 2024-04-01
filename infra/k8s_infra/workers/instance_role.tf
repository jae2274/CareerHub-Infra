
data "aws_iam_policy_document" "ec2_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = ["*"]
  }
}

#TODO: 이후 worker node에만 적용하고, master node에는 적용하지 않도록 수정
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



resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.cluster_name}-k8s_node-profile"
  role = aws_iam_role.k8s_node_role.name
}
