resource "aws_secretsmanager_secret" "kubeconfig" {
  name                    = "${var.cluster_name}-kubeconfig"
  recovery_window_in_days = 0
}

output "kubeconfig_secret_id" {
  value = aws_secretsmanager_secret.kubeconfig.name
}
