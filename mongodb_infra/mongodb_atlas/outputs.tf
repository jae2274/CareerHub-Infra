output "serverless_instances" {
  value = mongodbatlas_serverless_instance.mongodb_serverless
}

output "project_id" {
  value = mongodbatlas_project.project.id
}
