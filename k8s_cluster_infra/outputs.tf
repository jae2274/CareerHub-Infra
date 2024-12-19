

output "region" {
  value = var.region
}

output "vpc_id" {
  value = local.vpc_id
}

output "vpc_cidr_block" {
  value = local.vpc_cidr_block
}

output "private_subnets" {
  value = local.private_subnets
}

output "private_subnet_ids" {
  value = local.private_subnet_ids
}

output "private_subnet_arns" {
  value = local.private_subnet_arns
}


output "eks_cluster_name" {
  value = aws_eks_cluster.careerhub.name
}

output "eks_cluster_admin_config" {
  value = {
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    type       = "STANDARD"
  }
}

output "eks_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}
