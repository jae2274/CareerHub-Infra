data "aws_caller_identity" "current" {}

module "k8s_infra" {
  source = "./k8s_infra"

  vpc_id       = local.vpc_id
  cluster_name = local.prefix_service_name

  ecrs = [for key, ecr in toset([local.dataprovider_ecr, local.dataprocessor_ecr]) : ecr]

  master = {
    instance_type = "t3.small"
    subnet_id     = local.public_subnets[local.public_subnet_key_1].id
  }

  workers = {
    instance_type = "t3.small"
    worker = {
      "1" = {
        subnet_id = local.public_subnets[local.public_subnet_key_1].id
      }
      "2" = {
        subnet_id = local.public_subnets[local.public_subnet_key_2].id
      }
    }
  }

  cluster_user_arn = var.eks_cluster_user_arn
}

# resource "local_file" "temp" {
#   filename = "temp"
#   content  = "This is a temporary file"
# }

# resource "null_resource" "eks_connector" {
#   depends_on = [local_file.temp]

#   triggers = {
#     create  = "create"
#     destroy = "destroy"
#   }

#   provisioner "local-exec" {
#     when    = create
#     command = "echo ${self.triggers.create} > create.log"

#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = "echo ${self.triggers.destroy} > destroy.log"
#   }
# }
