resource "aws_secretsmanager_secret" "endpoint" {
  for_each = data.mongodbatlas_serverless_instance.serverless_instances

  name                           = replace("${local.prefix_service_name}-${each.key}-endpoint", "_", "-")
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "endpoint" {
  for_each = aws_secretsmanager_secret.endpoint

  secret_id     = each.value.id
  secret_string = data.mongodbatlas_serverless_instance.serverless_instances[each.key].connection_strings_private_endpoint_srv[0]
}

resource "aws_secretsmanager_secret" "username" {
  name                           = replace("${local.prefix_service_name}-mongo-username", "_", "-")
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "username" {
  secret_id     = aws_secretsmanager_secret.username.id
  secret_string = var.admin_db_username
}

resource "aws_secretsmanager_secret" "password" {
  name                           = replace("${local.prefix_service_name}-mongo-password", "_", "-")
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = var.admin_db_password
}
