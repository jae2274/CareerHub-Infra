terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas",
      version = "1.14.0"
    }
  }

}


provider "mongodbatlas" {
  public_key  = var.atlas_key.public_key
  private_key = var.atlas_key.private_key
}


data "mongodbatlas_roles_org_id" "organization" {
}

resource "mongodbatlas_project" "project" {
  name   = var.project_name
  org_id = data.mongodbatlas_roles_org_id.organization.id


  is_collect_database_specifics_statistics_enabled = true
  is_data_explorer_enabled                         = true
  is_extended_storage_sizes_enabled                = true
  is_performance_advisor_enabled                   = true
  is_realtime_performance_panel_enabled            = true
  is_schema_advisor_enabled                        = true
}

resource "mongodbatlas_serverless_instance" "mongodb_serverless" {
  for_each = toset(var.serverless_databases)

  project_id                              = mongodbatlas_project.project.id
  name                                    = each.key
  provider_settings_backing_provider_name = "AWS"
  provider_settings_provider_name         = "SERVERLESS"
  provider_settings_region_name           = join("_", split("-", upper(var.mongodb_region)))
  continuous_backup_enabled               = true


  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "mongodbatlas_database_user" "admin_db_user" {
  project_id         = mongodbatlas_project.project.id
  username           = var.admin_db_user.username
  password           = var.admin_db_user.password
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }

  # dynamic "roles" {
  #   for_each = mongodbatlas_serverless_instance.mongodb_serverless

  #   content {
  #     role_name     = "readWrite"
  #     database_name = roles.value.name
  #   }
  # }
}

resource "mongodbatlas_privatelink_endpoint_serverless" "privatelink_endpoint" {
  for_each = mongodbatlas_serverless_instance.mongodb_serverless

  project_id    = mongodbatlas_project.project.id
  instance_name = each.value.name
  provider_name = "AWS"
}


resource "aws_vpc_endpoint" "vpc_endpoint" {
  for_each = mongodbatlas_privatelink_endpoint_serverless.privatelink_endpoint

  vpc_id              = var.vpc_id
  service_name        = each.value.endpoint_service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = false

  security_group_ids = [var.mongodb_sg_id]
  subnet_ids         = var.subnet_ids
}

output "private_endpoint" {
  value = [for mongodb in mongodbatlas_serverless_instance.mongodb_serverless : mongodb.connection_strings_private_endpoint_srv[0]]
}
# resource "mongodbatlas_privatelink_endpoint_service_serverless" "privatelink_endpoint_service" {
#   for_each = mongodbatlas_privatelink_endpoint_serverless.privatelink_endpoint

#   project_id                 = mongodbatlas_project.project.id
#   instance_name              = each.value.instance_name
#   endpoint_id                = each.value.endpoint_id
#   cloud_provider_endpoint_id = aws_vpc_endpoint.vpc_endpoint[each.key].id
#   provider_name              = "AWS"
#   comment                    = "New serverless endpoint"
# }

