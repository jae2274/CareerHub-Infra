
module "cd_infra" {
  source = "./helm_repo_infra"

  helm_path = "helm/logApi"
}
