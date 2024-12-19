# locals {
#   lb_controller_iam_role_name        = replace("${local.prefix_service_name}-inhouse-eks-aws-lb-ctrl", "_", "-")
#   lb_controller_service_account_name = replace("${local.prefix_service_name}-aws-load-balancer-controller", "_", "-")
# }


# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#   }
# }



# module "lb_controller_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

#   create_role = true

#   role_name        = local.lb_controller_iam_role_name
#   role_path        = "/"
#   role_description = "Used by AWS Load Balancer Controller for EKS"

#   role_permissions_boundary_arn = ""

#   provider_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
#   oidc_fully_qualified_subjects = [
#     "system:serviceaccount:kube-system:${local.lb_controller_service_account_name}"
#   ]
#   oidc_fully_qualified_audiences = [
#     "sts.amazonaws.com"
#   ]
# }

# data "http" "iam_policy" {
#   url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.0/docs/install/iam_policy.json"
# }

# resource "aws_iam_role_policy" "controller" {
#   name_prefix = "AWSLoadBalancerControllerIAMPolicy"
#   policy      = data.http.iam_policy.body
#   role        = module.lb_controller_role.iam_role_name
# }

# resource "helm_release" "release" {
#   name       = replace("${local.prefix_service_name}-aws-load-balancer-controller", "_", "-")
#   chart      = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   namespace  = "kube-system"

#   dynamic "set" {
#     for_each = {
#       "clusterName"           = local.eks_cluster_name
#       "serviceAccount.create" = "true"
#       "serviceAccount.name"   = local.lb_controller_service_account_name
#       "region"                = local.region
#       "vpcId"                 = local.vpc_id
#       "image.repository"      = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"

#       "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.lb_controller_role.iam_role_arn
#     }
#     content {
#       name  = set.key
#       value = set.value
#     }
#   }
# }
