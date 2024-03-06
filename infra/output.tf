

output "finded_history_mongodb_endpoint_secret_id" {
  value = aws_secretsmanager_secret.finded_history_mongodb_endpoint.name
}

output "jobposting_mongodb_endpoint_secret_id" {
  value = aws_secretsmanager_secret.jobposting_mongodb_endpoint.name
}

output "log_mongodb_endpoint_secret_id" {
  value = aws_secretsmanager_secret.log_mongodb_endpoint.name
}

output "mongodb_username_secret_id" {
  value = aws_secretsmanager_secret.username_secret.name
}

output "mongodb_password_secret_id" {
  value = aws_secretsmanager_secret.password_secret.name
}

output "kubeconfig_secret_id" {
  value = local.kubeconfig_secret_id
}

output "dataprovider_ecr_name" {
  value = module.dataprovider_cicd.ecr_name
}
output "dataprocessor_ecr_name" {
  value = module.dataprocessor_cicd.ecr_name
}
output "skillscanner_ecr_name" {
  value = module.skillscanner_cicd.ecr_name
}
output "logapi_ecr_name" {
  value = module.logapi_cicd.ecr_name
}

output "region" {
  value = var.region
}

output "vpc_id" {
  value = local.vpc_id
}

output "private_subnet_ids" {
  value = [for subnet in local.private_subnets : subnet.id]
}

output "k8s_node_port" {
  value = local.node_port
}
