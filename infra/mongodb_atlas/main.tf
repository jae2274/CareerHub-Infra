terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.12.2"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.atlas_key.public_key
  private_key = var.atlas_key.private_key
}
#
#provider "mongodbatlas" {
#  public_key = var.atlas_key.public_key
#  private_key = var.atlas_key.private_key
#}


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


resource "mongodbatlas_privatelink_endpoint_serverless" "privatelink" {
  for_each = mongodbatlas_serverless_instance.mongodb_serverless

  project_id   = mongodbatlas_project.project.id
  instance_name = each.key
  provider_name = "AWS"
}

resource "mongodbatlas_serverless_instance" "mongodb_serverless" {
  for_each = toset(var.serverless_databases)

  project_id   = mongodbatlas_project.project.id
  name         = each.key
  provider_settings_backing_provider_name = "AWS"
  provider_settings_provider_name = "SERVERLESS"
  provider_settings_region_name = join("_",split("-",upper(var.mongodb_region)))
  continuous_backup_enabled = true

  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "mongodbatlas_database_user" "admin_db_user" {
  project_id = mongodbatlas_project.project.id
  username   = var.admin_db_user.username
  password   = var.admin_db_user.password
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
}