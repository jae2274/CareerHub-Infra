data "tls_certificate" "careerhub" {
  url = aws_eks_cluster.careerhub.identity.0.oidc.0.issuer
}

data "aws_eks_cluster" "careerhub" {
  name = aws_eks_cluster.careerhub.name
}

resource "aws_iam_openid_connect_provider" "careerhub" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.careerhub.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.careerhub.identity.0.oidc.0.issuer
}

# resource "aws_eks_identity_provider_config" "oidc" {
#   cluster_name = aws_eks_cluster.careerhub.name

#   oidc {
#     client_id                     = "sts.amazonaws.com"
#     identity_provider_config_name = "eks-oidc"
#     issuer_url                    = aws_iam_openid_connect_provider.careerhub.url
#   }
# }
