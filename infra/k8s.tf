data "aws_caller_identity" "current" {}

locals {
  cluster_name = local.prefix_service_name
  ami          = "ami-025a235c91853ccbe" # ubuntu 20.04 LTS arm64
}

resource "tls_private_key" "k8s_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k8s_keypair" {
  key_name   = "${local.cluster_name}-keypair.pem"
  public_key = tls_private_key.k8s_private_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  filename        = "k8s_infra/cluster/keypair/dev-careerhub-keypair.pem"
  content         = tls_private_key.k8s_private_key.private_key_pem
  file_permission = "0600"
}



data "aws_iam_policy_document" "ec2_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = ["*"]
  }
}

#TODO: 이후 worker node에만 적용하고, master node에는 적용하지 않도록 수정
data "aws_iam_policy_document" "assume_role_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "k8s_node_role" {
  name               = "${local.cluster_name}-k8s_node-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "ec2_role_policy" {
  role   = aws_iam_role.k8s_node_role.name
  policy = data.aws_iam_policy_document.ec2_policy_doc.json
}



resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${local.cluster_name}-k8s_node-profile"
  role = aws_iam_role.k8s_node_role.name
}


###########################################################################


#Security Group
#해당 보안 그룹을 가진 인스턴스들은 서로 모든 포트를 허용한다.
resource "aws_security_group" "k8s_node_sg" {
  vpc_id      = local.vpc_id
  name        = "${local.cluster_name}-node-sg"
  description = "For k8s worker nodes"
}


resource "aws_security_group_rule" "k8s_node_sg_rule" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1" # -1은 모든 프로토콜을 의미합니다.
  source_security_group_id = aws_security_group.k8s_node_sg.id
  security_group_id        = aws_security_group.k8s_node_sg.id
}
###########################################################################

module "k8s_infra" {
  source = "./k8s_infra/cluster"

  vpc_id       = local.vpc_id
  cluster_name = local.cluster_name

  ecrs = [for key, ecr in toset([local.careerhub_posting_provider_ecr, local.careerhub_posting_service_ecr]) : ecr]

  master = {
    instance_type = "t4g.small"
    subnet_id     = local.public_subnets[local.public_subnet_key_1].id
  }

  node_ports           = [local.careerhub_node_port, local.user_service_node_port]
  ami                  = local.ami
  key_name             = aws_key_pair.k8s_keypair.key_name
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name
  common_cluster_sg_id = aws_security_group.k8s_node_sg.id

  # workers = {
  #   instance_type = "t4g.small"
  #   worker = {
  #     "1" = {
  #       subnet_id = local.public_subnets[local.public_subnet_key_1].id
  #     }
  #     "2" = {
  #       subnet_id = local.public_subnets[local.public_subnet_key_2].id
  #     }
  #   }
  # }
}

locals {
  master_private_ip    = module.k8s_infra.master_private_ip
  master_public_ip     = module.k8s_infra.master_public_ip
  kubeconfig_secret_id = module.k8s_infra.kubeconfig_secret_id

}

data "aws_iam_policy_document" "cert_secret_policy_doc" {

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:PutSecretValue",
    ]
    resources = [module.k8s_infra.kubeconfig_secret_arn]
  }
}

resource "aws_iam_role_policy" "secrets_manager_policy" {
  role   = aws_iam_role.k8s_node_role.name
  policy = data.aws_iam_policy_document.cert_secret_policy_doc.json
}

module "worker_nodes" {
  source = "./k8s_infra/workers"

  vpc_id               = local.vpc_id
  cluster_name         = local.cluster_name
  key_name             = aws_key_pair.k8s_keypair.key_name
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name
  common_cluster_sg_id = aws_security_group.k8s_node_sg.id
  master_ip            = local.master_private_ip
  master_private_key   = tls_private_key.k8s_private_key.private_key_pem
  instance_type        = "t4g.small"

  workers = {
    "1" = {
      subnet_id = local.public_subnets[local.public_subnet_key_1].id
    }
    "2" = {
      subnet_id = local.public_subnets[local.public_subnet_key_2].id
    }
  }

  ecrs = [for key, ecr in toset([local.careerhub_posting_provider_ecr, local.careerhub_posting_service_ecr]) : ecr]
  ami  = local.ami
}

locals {
  worker_ips = module.worker_nodes.worker_public_ips
}
