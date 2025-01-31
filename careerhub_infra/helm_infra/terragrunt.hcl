terraform {
    source = "../infra_modules/helm"
}

include "root" {
    path = find_in_parent_folders("terragrunt.hcl")
    expose = true
}

include "aws_provider" {
    path = find_in_parent_folders("aws_provider.hcl")
}


inputs = {
    env = include.root.locals.env
    prefix = include.root.locals.prefix
    region = include.root.locals.region
    service_name = include.root.locals.service_name
    
    terraform_role = include.root.locals.terraform_role
}