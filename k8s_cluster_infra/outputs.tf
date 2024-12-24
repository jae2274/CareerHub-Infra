
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

