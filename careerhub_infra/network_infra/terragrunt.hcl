include "env" {
    path = find_in_parent_folders("env.hcl")
    expose = true
    merge_strategy = "no_merge"
}

include "root" {
    path = find_in_parent_folders("terragrunt.hcl")
    expose = true
}





inputs = {
    service_name = include.root.locals.service_name
    region = include.root.locals.region
    terraform_role = include.root.locals.terraform_role

    env = include.env.locals.env
}