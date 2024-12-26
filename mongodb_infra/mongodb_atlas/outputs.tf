output "serverless_instances" {
  value = mongodbatlas_serverless_instance.mongodb_serverless
}

output "public_endpoint" {
  value = { for key, mongodb in mongodbatlas_serverless_instance.mongodb_serverless : key => mongodb.connection_strings_standard_srv }
}

output "project_id" {
  value = mongodbatlas_project.project.id
}
