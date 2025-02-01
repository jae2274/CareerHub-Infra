terraform {
    source = "../../infra_modules/core"
}

include "root" {
    path = find_in_parent_folders("terragrunt.hcl")
    expose = true
}

include "aws_provider" {
    path = find_in_parent_folders("aws_provider.hcl")
}

include "mongodbatlas_provider" {
    path = find_in_parent_folders("mongodbatlas_provider.hcl")
}

dependency "network" {
    config_path = "../network_infra"  # VPC 모듈의 Terragrunt 설정 파일 위치
    mock_outputs = {
        region = ""
        vpc_id = ""
        public_subnet_ids = {}
        public_subnet_key_1 = ""
        public_subnet_key_2 = ""
        public_subnet_key_3 = ""
    }
}

dependency "k8s_cluster" {
    config_path = "../k8s_cluster_infra"  # VPC 모듈의 Terragrunt 설정 파일 위치
}

dependency "mongodb" {
    config_path = "../mongodb_infra"
}

dependency "helm" {
    config_path = "../helm_infra"
}

inputs = {
    env = include.root.locals.env
    prefix = include.root.locals.prefix
    branch = include.root.locals.branch

    terraform_role = include.root.locals.terraform_role

    atlas_public_key = include.root.locals.atlas_public_key
    atlas_private_key = include.root.locals.atlas_private_key

    google_client_id = include.root.locals.google_client_id
    google_client_secret = include.root.locals.google_client_secret
    google_redirect_path = include.root.locals.google_redirect_path

    initialAdminPassword = include.root.locals.initialAdminPassword
    jwt_secretkey        = include.root.locals.jwt_secretkey
    mysql_admin_password = include.root.locals.mysql_admin_password
    mysql_admin_username = include.root.locals.mysql_admin_username
    mysql_db_name        = include.root.locals.mysql_db_name
    root_domain_name     = include.root.locals.root_domain_name
    
    
    vpc_id              = dependency.network.outputs.vpc_id
    region              = dependency.network.outputs.region

    vpc_cidr_block      = dependency.network.outputs.vpc_cidr_block
    private_subnet_ids  = dependency.network.outputs.private_subnet_ids

    master_public_ip     = dependency.k8s_cluster.outputs.master_public_ip
    worker_ips           = dependency.k8s_cluster.outputs.worker_ips
    kubeconfig_secret_id = dependency.k8s_cluster.outputs.kubeconfig_secret_id


    mongodb_project_id = dependency.mongodb.outputs.mongodb_project_id

    jobposting_mongodb_endpoint = dependency.mongodb.outputs.jobposting_mongodb_endpoint
    userinfo_mongodb_endpoint   = dependency.mongodb.outputs.userinfo_mongodb_endpoint
    review_mongodb_endpoint     = dependency.mongodb.outputs.review_mongodb_endpoint

    mongodb_username_secret_id = dependency.mongodb.outputs.mongodb_username_secret_id
    mongodb_password_secret_id = dependency.mongodb.outputs.mongodb_password_secret_id


    namespace                                      = dependency.helm.outputs.namespace
    careerhub_posting_service_helm_chart_repo      = dependency.helm.outputs.careerhub_posting_service_helm_chart_repo
    careerhub_posting_provider_helm_chart_repo     = dependency.helm.outputs.careerhub_posting_provider_helm_chart_repo
    careerhub_posting_skillscanner_helm_chart_repo = dependency.helm.outputs.careerhub_posting_skillscanner_helm_chart_repo
    careerhub_userinfo_service_helm_chart_repo     = dependency.helm.outputs.careerhub_userinfo_service_helm_chart_repo
    careerhub_api_composer_helm_chart_repo         = dependency.helm.outputs.careerhub_api_composer_helm_chart_repo
    careerhub_review_service_helm_chart_repo       = dependency.helm.outputs.careerhub_review_service_helm_chart_repo
    careerhub_review_crawler_helm_chart_repo       = dependency.helm.outputs.careerhub_review_crawler_helm_chart_repo

    log_system_helm_chart_repo = dependency.helm.outputs.log_system_helm_chart_repo


    auth_service_helm_chart_repo = dependency.helm.outputs.auth_service_helm_chart_repo
    careerhub_node_port          = dependency.helm.outputs.careerhub_node_port
    auth_service_node_port       = dependency.helm.outputs.auth_service_node_port
}

