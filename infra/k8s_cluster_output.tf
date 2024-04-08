locals {
  k8s_cluster_infra_outputs = data.terraform_remote_state.k8s_cluster_infra.outputs

  region              = local.k8s_cluster_infra_outputs.region
  vpc_id              = local.k8s_cluster_infra_outputs.vpc_id
  vpc_cidr_block      = local.k8s_cluster_infra_outputs.vpc_cidr_block
  private_subnet_ids  = local.k8s_cluster_infra_outputs.private_subnet_ids
  private_subnet_arns = local.k8s_cluster_infra_outputs.private_subnet_arns

  master_public_ip     = local.k8s_cluster_infra_outputs.master_public_ip
  worker_ips           = local.k8s_cluster_infra_outputs.worker_ips
  kubeconfig_secret_id = local.k8s_cluster_infra_outputs.kubeconfig_secret_id
}
