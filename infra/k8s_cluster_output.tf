locals {
  k8s_cluster_infra_outputs = data.terraform_remote_state.k8s_cluster_infra.outputs

  region              = local.k8s_cluster_infra_outputs.region
  vpc_id              = local.k8s_cluster_infra_outputs.vpc_id
  vpc_cidr_block      = local.k8s_cluster_infra_outputs.vpc_cidr_block
  private_subnet_ids  = local.k8s_cluster_infra_outputs.private_subnet_ids
  private_subnet_arns = local.k8s_cluster_infra_outputs.private_subnet_arns

  eks_cluster_name = local.k8s_cluster_infra_outputs.eks_cluster_name

  eks_admin_policy_arn = local.k8s_cluster_infra_outputs.eks_cluster_admin_config.policy_arn
  eks_admin_type       = local.k8s_cluster_infra_outputs.eks_cluster_admin_config.type
}
