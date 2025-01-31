terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas",
      version = "1.14.0"
    }
  }
}



locals {
  mongodb_region = join("_", split("-", upper(var.mongodb_region)))
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
  provider_settings_region_name           = local.mongodb_region
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

}

output "mongodb_project_id" {
  value = mongodbatlas_project.project.id
}

output "public_endpoint" {
  value = { for key, mongodb in mongodbatlas_serverless_instance.mongodb_serverless : key => mongodb.connection_strings_standard_srv }
}

