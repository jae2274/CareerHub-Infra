
# resource "aws_eks_access_entry" "node_group" {
#   principal_arn = aws_iam_role.node_group.arn
#   cluster_name  = aws_eks_cluster.careerhub.name
# }
locals {
  cluster_admins = [
    for admin_arn in concat(var.eks_cluster_admin_role_arns, var.eks_cluster_admin_user_arns) : {
      principal_arn     = admin_arn
      kubernetes_groups = []
      username          = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      type              = "STANDARD"
    }
  ]
}

resource "aws_eks_access_entry" "cluster_admins" {
  for_each = { for idx, role in local.cluster_admins : idx => role }

  cluster_name      = aws_eks_cluster.careerhub.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = each.value.kubernetes_groups
  type              = each.value.type
}

resource "aws_eks_access_policy_association" "cluster_admins" {
  for_each = { for idx, role in local.cluster_admins : idx => role }

  cluster_name  = aws_eks_cluster.careerhub.name
  policy_arn    = each.value.username
  principal_arn = each.value.principal_arn

  access_scope {
    type = "cluster"
  }
}
