resource "aws_security_group" "mongodb_security_group" {
  name        = "mongodb_security_group"
  description = "mongodb_security_group"
  vpc_id      = var.vpc_id

  ingress {
    description = "mongodb ingress"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "mongodbatlas_project_ip_access_list" "ip_access_list" {
  count = length(var.worker_ips)

  project_id = var.mongodb_project_id
  cidr_block = "${var.worker_ips[count.index]}/32"
  comment    = "Access from ${var.worker_ips[count.index]}"
}

resource "aws_secretsmanager_secret" "jobposting_mongodb_endpoint" {
  name                    = "${local.prefix_service_name}-jobposting-mongodb-endpoint"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "jobposting_mongodb_endpoint" {
  secret_id     = aws_secretsmanager_secret.jobposting_mongodb_endpoint.id
  secret_string = var.jobposting_mongodb_endpoint
}

resource "aws_secretsmanager_secret" "userinfo_mongodb_endpoint" {
  name                    = "${local.prefix_service_name}-userinfo-mongodb-endpoint"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "userinfo_mongodb_endpoint" {
  secret_id     = aws_secretsmanager_secret.userinfo_mongodb_endpoint.id
  secret_string = var.userinfo_mongodb_endpoint
}

resource "aws_secretsmanager_secret" "review_mongodb_endpoint" {
  name                    = "${local.prefix_service_name}-review-mongodb-endpoint"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "review_mongodb_endpoint" {
  secret_id     = aws_secretsmanager_secret.review_mongodb_endpoint.id
  secret_string = var.review_mongodb_endpoint
}



locals {
  jobposting_mongodb_endpoint_secret_id = aws_secretsmanager_secret.jobposting_mongodb_endpoint.name
  userinfo_mongodb_endpoint_secret_id   = aws_secretsmanager_secret.userinfo_mongodb_endpoint.name
  review_mongodb_endpoint_secret_id     = aws_secretsmanager_secret.review_mongodb_endpoint.name
}
