locals {
  network_output = data.terraform_remote_state.network_infra.outputs

  region         = local.network_output.region
  vpc_id         = local.network_output.vpc_id
  public_subnets = local.network_output.public_subnets

  public_subnet_key_1 = local.network_output.public_subnet_key_1
  public_subnet_key_2 = local.network_output.public_subnet_key_2
  public_subnet_key_3 = local.network_output.public_subnet_key_3
}
