resource "aws_rds_cluster" "user_mysql" {
  cluster_identifier     = "${local.prefix_service_name}-usermysql"
  engine                 = "aurora-mysql"
  engine_version         = "5.7.mysql_aurora.2.11.4"
  db_subnet_group_name   = aws_db_subnet_group.user_mysql_subnet_group.name
  vpc_security_group_ids = [aws_security_group.user_mysql_sg.id]
  master_username        = var.mysql_admin_username
  master_password        = var.mysql_admin_password
  database_name          = var.mysql_db_name
  skip_final_snapshot    = true

  // To enable serverless
  engine_mode = "serverless"
  scaling_configuration {
    auto_pause               = true
    min_capacity             = 1
    max_capacity             = 32
    seconds_until_auto_pause = 300
  }
}

resource "aws_db_subnet_group" "user_mysql_subnet_group" {
  name       = "${local.prefix_service_name}-usermysql-subnets"
  subnet_ids = local.private_subnet_ids
}

resource "aws_security_group" "user_mysql_sg" {
  name        = "${local.prefix_service_name}-usermysql-sg"
  description = "Allow traffic to user_mysql"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_secretsmanager_secret" "usermysql_endpoint" {
  name = "${local.prefix_service_name}-usermysql-endpoint"
}

resource "aws_secretsmanager_secret_version" "usermysql_endpoint" {
  secret_id     = aws_secretsmanager_secret.usermysql_endpoint.id
  secret_string = aws_rds_cluster.user_mysql.endpoint
}

resource "aws_secretsmanager_secret" "usermysql_dbname" {
  name = "${local.prefix_service_name}-usermysql-dbname"
}

resource "aws_secretsmanager_secret_version" "usermysql_dbname" {
  secret_id     = aws_secretsmanager_secret.usermysql_dbname.id
  secret_string = var.mysql_db_name
}

resource "aws_secretsmanager_secret" "usermysql_username" {
  name = "${local.prefix_service_name}-usermysql-username"
}

resource "aws_secretsmanager_secret_version" "usermysql_username" {
  secret_id     = aws_secretsmanager_secret.usermysql_username.id
  secret_string = var.mysql_admin_username
}

resource "aws_secretsmanager_secret" "usermysql_password" {
  name = "${local.prefix_service_name}-usermysql-password"
}

resource "aws_secretsmanager_secret_version" "usermysql_password" {
  secret_id     = aws_secretsmanager_secret.usermysql_password.id
  secret_string = var.mysql_admin_password
}


locals {
  user_mysql_endpoint_secret_id = aws_secretsmanager_secret.usermysql_endpoint.id
  user_mysql_dbname_secret_id   = aws_secretsmanager_secret.usermysql_dbname.id
  user_mysql_username_secret_id = aws_secretsmanager_secret.usermysql_username.id
  user_mysql_password_secret_id = aws_secretsmanager_secret.usermysql_password.id
}
