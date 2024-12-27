locals {
  network_remote_state = data.terraform_remote_state.network_infra.outputs

  region         = local.network_remote_state.region
  vpc_id         = local.network_remote_state.vpc_id
  vpc_cidr_block = local.network_remote_state.vpc_cidr_block

  public_route_table  = local.network_remote_state.public_route_table
  private_route_table = local.network_remote_state.private_route_table

  public_subnet_ids  = [for subnet in local.network_remote_state.public_subnets : subnet.id]
  private_subnet_ids = [for subnet in local.network_remote_state.private_subnets : subnet.id]

  public_subnet_arns  = [for subnet in local.network_remote_state.public_subnets : subnet.arn]
  private_subnet_arns = [for subnet in local.network_remote_state.private_subnets : subnet.arn]
}
