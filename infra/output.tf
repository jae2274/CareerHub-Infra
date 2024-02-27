output "mongodb_user_secret_id" {
  value = aws_secretsmanager_secret.secretmanager.id
}

output "finded_history_mongodb_endpoint" {
  value = module.mongodb_atlas.public_endpoint[local.finded_history_db]
}

output "jobposting_mongodb_endpoint" {
  value = module.mongodb_atlas.public_endpoint[local.jobposting_db]
}

output "log_mongodb_endpoint" {
  value = module.mongodb_atlas.public_endpoint[local.log_db]
}

output "dataprovider_ecr" {
  value = module.dataprovider_cicd.ecr_url
}
output "dataprocessor_ecr" {
  value = module.dataprocessor_cicd.ecr_url
}
output "skillscanner_ecr" {
  value = module.skillscanner_cicd.ecr_url
}
output "logapi_ecr" {
  value = module.logapi_cicd.ecr_url
}

output "other_latest_tag" {
  value = local.other_latest_tag
}

output "region" {
  value = var.region
}
