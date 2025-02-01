output "region" {
  value = var.region
}

output "vpc_id" {
  value = local.vpc_id
}

output "vpc_cidr_block" {
  value = local.vpc_cidr_block
}

output "public_route_table" {
  value = module.vpc_infra.public_route_table
}

output "public_subnet_key_1" {
  value = local.public_subnet_key_1
}

output "public_subnet_key_2" {
  value = local.public_subnet_key_2
}

output "public_subnet_key_3" {
  value = local.public_subnet_key_3
}

output "public_subnet_ids" {
  value = { for k, v in local.public_subnets : k => v.id }
}

output "private_subnets" {
  value = local.private_subnets
}

output "private_subnet_ids" {
  value = { for k, v in local.private_subnets : k => v.id }
}

output "private_route_table" {
  value = module.private_subnet_infra.private_route_table
}
