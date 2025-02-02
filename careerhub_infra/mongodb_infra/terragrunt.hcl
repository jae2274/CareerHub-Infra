terraform {
    source = "../../infra_modules/mongodb"
}

include "root" {
    path = find_in_parent_folders("terragrunt.hcl")
    expose = true
}

include "mongodbatlas_provider" {
    path = find_in_parent_folders("mongodbatlas_provider.hcl")
}

include "aws_provider" {
    path = find_in_parent_folders("aws_provider.hcl")
}

inputs = {
    env = include.root.locals.env
    prefix = include.root.locals.prefix
    region = include.root.locals.region
    
    terraform_role = include.root.locals.terraform_role

    admin_db_username = include.root.locals.admin_db_username
    admin_db_password = include.root.locals.admin_db_password
    atlas_public_key = include.root.locals.atlas_public_key
    atlas_private_key = include.root.locals.atlas_private_key
}