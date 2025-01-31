terraform {
    source = "../infra_modules/k8s_cluster"
}

include "root" {
    path = find_in_parent_folders("terragrunt.hcl")
    expose = true
}

include "aws_provider" {
    path = find_in_parent_folders("aws_provider.hcl")
}

dependency "network" {
  config_path = "../network_infra"  # VPC 모듈의 Terragrunt 설정 파일 위치
}

inputs = {
    env = include.root.locals.env
    prefix = include.root.locals.prefix
    service_name = include.root.locals.service_name

    terraform_role = include.root.locals.terraform_role

    ssh_public_key_path = include.root.locals.k8s_ssh_public_key_path
    ssh_private_key_path = include.root.locals.k8s_ssh_private_key_path

    region = dependency.network.outputs.region
    vpc_id = dependency.network.outputs.vpc_id
    public_subnet_ids = dependency.network.outputs.public_subnet_ids
    public_subnet_key_1 = dependency.network.outputs.public_subnet_key_1
    public_subnet_key_2 = dependency.network.outputs.public_subnet_key_2
    public_subnet_key_3 = dependency.network.outputs.public_subnet_key_3
}