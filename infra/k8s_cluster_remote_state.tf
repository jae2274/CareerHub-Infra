locals {
  k8s_cluster_infra_outputs = data.terraform_remote_state.k8s_cluster_infra.outputs


  eks_cluster_name = local.k8s_cluster_infra_outputs.eks_cluster_name

  eks_admin_policy_arn = local.k8s_cluster_infra_outputs.eks_cluster_admin_config.policy_arn
  eks_admin_type       = local.k8s_cluster_infra_outputs.eks_cluster_admin_config.type
}
