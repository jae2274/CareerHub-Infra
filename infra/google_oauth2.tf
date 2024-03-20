
resource "aws_secretsmanager_secret" "google_client_id" {
  name = "${local.prefix_service_name}-google-client-id"
}

resource "aws_secretsmanager_secret_version" "google_client_id" {
  secret_id     = aws_secretsmanager_secret.google_client_id.id
  secret_string = var.google_client_id
}

resource "aws_secretsmanager_secret" "google_client_secret" {
  name = "${local.prefix_service_name}-google-client-secret"
}

resource "aws_secretsmanager_secret_version" "google_client_secret" {
  secret_id     = aws_secretsmanager_secret.google_client_secret.id
  secret_string = var.google_client_secret
}

resource "aws_secretsmanager_secret" "google_redirecturi" {
  name = "${local.prefix_service_name}-google-redirect-uri"
}

resource "aws_secretsmanager_secret_version" "google_redirecturi" {
  secret_id     = aws_secretsmanager_secret.google_redirecturi.id
  secret_string = var.google_redirecturi
}


locals {
  google_client_id_secret_id     = aws_secretsmanager_secret.google_client_id.id
  google_client_secret_secret_id = aws_secretsmanager_secret.google_client_secret.id
  google_redirect_uri_secret_id  = aws_secretsmanager_secret.google_redirecturi.id
}
