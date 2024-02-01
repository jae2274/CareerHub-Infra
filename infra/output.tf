output "jobposting_mongodb_endpoint" {
  value = module.mongodb_atlas.private_endpoint[local.jobposting_db]
}

output "log_mongodb_endpoint" {
  value = module.mongodb_atlas.private_endpoint[local.log_db]
}

output "dataprovider_ecr" {
  value = module.dataprovider_cicd.ecr_url
}
output "dataprocessor_ecr" {
  value = module.dataprocessor_cicd.ecr_url
}

output "other_latest_tag" {
  value = local.other_latest_tag
}
