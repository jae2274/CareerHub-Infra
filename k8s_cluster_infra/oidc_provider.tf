# resource "aws_eks_identity_provider_config" "oidc" {
#   cluster_name = aws_eks_cluster.example.name

#   oidc {
#     client_id                     = 
#     identity_provider_config_name = "oidc"
#     issuer_url                    = aws_eks_cluster.careerhub.identity.0.oidc.0.issuer
#   }
# }
