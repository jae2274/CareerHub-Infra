terraform {
    source = "../../infra_modules/network"
}

include "root" {
    path = find_in_parent_folders("terragrunt.hcl")
    expose = true
}

include "aws_provider" {
    path = find_in_parent_folders("aws_provider.hcl")
}


inputs = {
    service_name = include.root.locals.service_name
    region = include.root.locals.region
    terraform_role = include.root.locals.terraform_role

    env = include.root.locals.env
    prefix = include.root.locals.prefix
}