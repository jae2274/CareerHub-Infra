

resource "aws_secretsmanager_secret" "jwt_secretkey" {
  name                           = "${local.prefix_service_name}-jwt-secretkey"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "jwt_secretkey" {
  secret_id     = aws_secretsmanager_secret.jwt_secretkey.id
  secret_string = var.jwt_secretkey
}

locals {
  jwt_secretkey_secret_id = aws_secretsmanager_secret.jwt_secretkey.id
}


#codebuild에서 사용할 역할을 생성합니다.
data "aws_iam_policy_document" "codebuild_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:*:*:network-interface/*"]

    condition {
      test     = "ArnEquals"
      variable = "ec2:Subnet"

      values = local.private_subnet_arns
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["eks:*"]
    resources = [data.aws_eks_cluster.cluster.arn]
  }
}

data "aws_iam_policy_document" "codebuild_assume_role_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "helm_cd_role" {
  name               = replace("${local.prefix_service_name}-helm-cb", "_", "-")
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role   = aws_iam_role.helm_cd_role.name
  policy = data.aws_iam_policy_document.codebuild_policy_doc.json
}

resource "aws_eks_access_entry" "cluster_admins" {

  cluster_name      = local.eks_cluster_name
  principal_arn     = aws_iam_role.helm_cd_role.arn
  kubernetes_groups = []
  type              = local.eks_admin_type
}

resource "aws_eks_access_policy_association" "cluster_admins" {

  cluster_name  = local.eks_cluster_name
  policy_arn    = local.eks_admin_policy_arn
  principal_arn = aws_iam_role.helm_cd_role.arn

  access_scope {
    type = "cluster"
  }
}
// end define iam role and policy





module "careerhub_posting_service_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name = "${local.prefix_service_name}-careerhub-posting-service-helm"
  chart_repo  = local.careerhub_posting_service_helm_chart_repo
  cd_role_arn = aws_iam_role.helm_cd_role.arn

  ecr_repo_name    = local.careerhub_posting_service_ecr_name
  vpc_id           = local.vpc_id
  subnet_ids       = local.private_subnet_ids
  subnet_arns      = local.private_subnet_arns
  eks_cluster_name = local.eks_cluster_name

  helm_value_secret_ids = {
    "mongoUri"   = local.jobposting_db_private_endpoint_secret_id
    "dbUsername" = local.mongodb_username_secret_id
    "dbPassword" = local.mongodb_password_secret_id
  }
}

module "careerhub_posting_provider_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name      = "${local.prefix_service_name}-careerhub-posting-provider-helm"
  chart_repo       = local.careerhub_posting_provider_helm_chart_repo
  cd_role_arn      = aws_iam_role.helm_cd_role.arn
  ecr_repo_name    = local.careerhub_posting_provider_ecr_name
  vpc_id           = local.vpc_id
  subnet_ids       = local.private_subnet_ids
  subnet_arns      = local.private_subnet_arns
  eks_cluster_name = local.eks_cluster_name

  helm_value_secret_ids = {}
}

module "careerhub_posting_skillscanner_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name      = "${local.prefix_service_name}-careerhub-posting-skillscanner-helm"
  chart_repo       = local.careerhub_posting_skillscanner_helm_chart_repo
  ecr_repo_name    = local.careerhub_posting_skillscanner_ecr_name
  cd_role_arn      = aws_iam_role.helm_cd_role.arn
  eks_cluster_name = local.eks_cluster_name

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {}
}

module "careerhub_userinfo_service_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name      = "${local.prefix}careerhub-userinfo-service-helm"
  chart_repo       = local.careerhub_userinfo_service_helm_chart_repo
  ecr_repo_name    = local.careerhub_userinfo_service_ecr_name
  cd_role_arn      = aws_iam_role.helm_cd_role.arn
  eks_cluster_name = local.eks_cluster_name

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    "mongoUri"   = local.userinfo_db_private_endpoint_secret_id
    "dbUsername" = local.mongodb_username_secret_id
    "dbPassword" = local.mongodb_password_secret_id
  }
}

module "careerhub_api_composer_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name      = "${local.prefix_service_name}-careerhub-api-composer-helm"
  chart_repo       = local.careerhub_api_composer_helm_chart_repo
  ecr_repo_name    = local.careerhub_api_composer_ecr_name
  cd_role_arn      = aws_iam_role.helm_cd_role.arn
  eks_cluster_name = local.eks_cluster_name

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    secretKey = local.jwt_secretkey_secret_id
  }

  helm_values = {
    "rootPath" = local.backend_root_path
  }
}

module "auth_service_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name      = "${local.prefix_service_name}-auth-service-helm"
  chart_repo       = local.auth_service_helm_chart_repo
  ecr_repo_name    = local.auth_service_ecr_name
  cd_role_arn      = aws_iam_role.helm_cd_role.arn
  eks_cluster_name = local.eks_cluster_name

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    dbHost             = local.user_mysql_endpoint_secret_id
    dbPort             = local.user_mysql_dbport_secret_id
    dbName             = local.user_mysql_dbname_secret_id
    dbUsername         = local.user_mysql_username_secret_id
    dbPassword         = local.user_mysql_password_secret_id
    googleClientId     = local.google_client_id_secret_id
    googleClientSecret = local.google_client_secret_secret_id
    googleRedirectUrl  = local.google_redirect_uri_secret_id
    secretKey          = local.jwt_secretkey_secret_id
  }
}

module "careerhub_review_service_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name      = "${local.prefix_service_name}-careerhub-review-service-helm"
  chart_repo       = local.careerhub_review_service_helm_chart_repo
  ecr_repo_name    = local.careerhub_review_service_ecr_name
  cd_role_arn      = aws_iam_role.helm_cd_role.arn
  eks_cluster_name = local.eks_cluster_name

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    "mongoUri"   = local.review_db_private_endpoint_secret_id
    "dbUsername" = local.mongodb_username_secret_id
    "dbPassword" = local.mongodb_password_secret_id
  }
}
module "careerhub_review_crawler_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name      = "${local.prefix_service_name}-careerhub-review-crawler-helm"
  chart_repo       = local.careerhub_review_crawler_helm_chart_repo
  ecr_repo_name    = local.careerhub_review_crawler_ecr_name
  cd_role_arn      = aws_iam_role.helm_cd_role.arn
  eks_cluster_name = local.eks_cluster_name

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {}
}


resource "aws_secretsmanager_secret" "initial_admin_password" {
  name                           = "${local.prefix_service_name}-opensearch-password"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "initial_admin_password" {
  secret_id     = aws_secretsmanager_secret.initial_admin_password.id
  secret_string = var.initialAdminPassword
}

module "log_system_helm_deploy" {
  source    = "./helm_deploy_infra"
  namespace = local.namespace

  deploy_name      = "${local.prefix_service_name}-log-system-helm"
  chart_repo       = local.log_system_helm_chart_repo
  cd_role_arn      = aws_iam_role.helm_cd_role.arn
  eks_cluster_name = local.eks_cluster_name

  vpc_id      = local.vpc_id
  subnet_ids  = local.private_subnet_ids
  subnet_arns = local.private_subnet_arns

  helm_value_secret_ids = {
    initialAdminPassword = aws_secretsmanager_secret.initial_admin_password.name
  }
}
