
# resource "aws_eks_access_entry" "node_group" {
#   principal_arn = aws_iam_role.node_group.arn
#   cluster_name  = aws_eks_cluster.careerhub.name
# }
locals {
  cluster_admins = {
    for admin_arn in concat(var.eks_cluster_admin_role_arns, var.eks_cluster_admin_user_arns) : admin_arn => {
      principal_arn     = admin_arn
      kubernetes_groups = []
      username          = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      type              = "STANDARD"
    }
  }

  terraform_admin = {
    principal_arn     = var.terraform_role
    kubernetes_groups = []
    username          = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    type              = "STANDARD"
  }
}



resource "aws_eks_access_entry" "cluster_admins" {
  for_each = local.cluster_admins

  cluster_name      = aws_eks_cluster.careerhub.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = each.value.kubernetes_groups
  type              = each.value.type
}

resource "aws_eks_access_policy_association" "cluster_admins" {
  # for_each = { for idx, role in local.cluster_admins : idx => role }
  for_each = aws_eks_access_entry.cluster_admins

  cluster_name  = aws_eks_cluster.careerhub.name
  policy_arn    = local.cluster_admins[each.key].username
  principal_arn = local.cluster_admins[each.key].principal_arn

  access_scope {
    type = "cluster"
  }
}


resource "aws_eks_access_entry" "terraform_admin" {
  cluster_name      = aws_eks_cluster.careerhub.name
  principal_arn     = local.terraform_admin.principal_arn
  kubernetes_groups = local.terraform_admin.kubernetes_groups
  type              = local.terraform_admin.type
}

resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = aws_eks_cluster.careerhub.name
  policy_arn    = local.terraform_admin.username
  principal_arn = local.terraform_admin.principal_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.terraform_admin
  ]
}
