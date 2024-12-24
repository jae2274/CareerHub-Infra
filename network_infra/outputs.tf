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

output "public_subnets" {
  value = local.public_subnets
}

output "private_subnets" {
  value = local.private_subnets
}

output "private_route_table" {
  value = module.private_subnet_infra.private_route_table
}
