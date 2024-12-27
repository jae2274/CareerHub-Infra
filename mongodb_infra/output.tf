
output "jobposting_db_private_endpoint" {
  value = data.mongodbatlas_serverless_instance.serverless_instances[local.jobposting_db].connection_strings_private_endpoint_srv
}

output "jobposting_db_endpoint_secret_id" {
  value = aws_secretsmanager_secret.endpoint[local.jobposting_db].id
}

output "review_db_private_endpoint" {
  value = data.mongodbatlas_serverless_instance.serverless_instances[local.review_db].connection_strings_private_endpoint_srv
}

output "review_db_endpoint_secret_id" {
  value = aws_secretsmanager_secret.endpoint[local.review_db].id
}

output "userinfo_db_private_endpoint" {
  value = data.mongodbatlas_serverless_instance.serverless_instances[local.userinfo_db].connection_strings_private_endpoint_srv
}

output "userinfo_db_endpoint_secret_id" {
  value = aws_secretsmanager_secret.endpoint[local.userinfo_db].id
}

output "mongodb_username_secret_id" {
  value = aws_secretsmanager_secret.username.id
}

output "mongodb_password_secret_id" {
  value = aws_secretsmanager_secret.password.id
}
