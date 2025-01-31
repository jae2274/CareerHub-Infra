locals {
  network_output = data.terraform_remote_state.network_infra.outputs

  region         = local.network_output.region
  vpc_id         = local.network_output.vpc_id
  public_subnets = local.network_output.public_subnets

  public_subnet_key_1 = local.network_output.public_subnet_key_1
  public_subnet_key_2 = local.network_output.public_subnet_key_2
  public_subnet_key_3 = local.network_output.public_subnet_key_3
}


output "region" {
  value = local.region
}

output "vpc_id" {
  value = local.vpc_id
}

output "vpc_cidr_block" {
  value = local.network_output.vpc_cidr_block
}

output "private_subnets" {
  value = local.network_output.private_subnets
}

output "private_subnet_arns" {
  value = [for subnet in local.network_output.private_subnets : subnet.arn]
}

output "private_subnet_ids" {
  value = [for subnet in local.network_output.private_subnets : subnet.id]
}
