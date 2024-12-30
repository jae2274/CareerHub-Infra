data "aws_eks_cluster" "cluster" {
  name = local.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

locals {
  ingress_port = 80
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = replace("${local.prefix_service_name}-ingress", "_", "-")
    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    ingress_class_name = "alb"
    default_backend {
      service {
        name = replace("${local.prefix_service_name}-backend", "_", "-")
        port { number = local.ingress_port }
      }
    }
    rule {
      http {
        path {
          backend {
            service {
              name = local.api_composer_service.name
              port {
                number = local.api_composer_service.port
              }
            }
          }

          path = local.backend_root_path
        }

        path {
          backend {
            service {
              name = local.auth_service.name
              port {
                number = local.auth_service.port
              }
            }
          }

          path = "/auth"
        }
      }
    }
  }
}
