output "mongodb_project_id" {
  value = module.mongodb_atlas.mongodb_project_id
}

output "jobposting_mongodb_endpoint" {
  value = module.mongodb_atlas.public_endpoint[local.jobposting_db]
}

output "userinfo_mongodb_endpoint" {
  value = module.mongodb_atlas.public_endpoint[local.userinfo_db]
}

output "review_mongodb_endpoint" {
  value = module.mongodb_atlas.public_endpoint[local.review_db]
}



output "mongodb_username_secret_id" {
  value = aws_secretsmanager_secret.username_secret.name
}

output "mongodb_password_secret_id" {
  value = aws_secretsmanager_secret.password_secret.name
}
