resource "aws_secretsmanager_secret" "kubeconfig" {
  name                    = "${var.cluster_name}-kubeconfig"
  recovery_window_in_days = 0
}



data "aws_iam_policy_document" "cert_secret_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:PutSecretValue",
    ]
    resources = [aws_secretsmanager_secret.kubeconfig.arn]
  }
}
