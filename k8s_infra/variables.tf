locals {
  infra_outputs = data.terraform_remote_state.infra.outputs

  mongodb_username_secret_id = local.infra_outputs.mongodb_username_secret_id
  mongodb_password_secret_id = local.infra_outputs.mongodb_password_secret_id

  finded_history_mongodb_endpoint_secret_id = local.infra_outputs.finded_history_mongodb_endpoint_secret_id
  jobposting_mongodb_endpoint_secret_id     = local.infra_outputs.jobposting_mongodb_endpoint_secret_id
  log_mongodb_endpoint_secret_id            = local.infra_outputs.log_mongodb_endpoint_secret_id
  kubeconfig_secret_id                      = local.infra_outputs.kubeconfig_secret_id
  dataprovider_ecr_name                     = local.infra_outputs.dataprovider_ecr_name
  dataprocessor_ecr_name                    = local.infra_outputs.dataprocessor_ecr_name
  skillscanner_ecr_name                     = local.infra_outputs.skillscanner_ecr_name
  logapi_ecr_name                           = local.infra_outputs.logapi_ecr_name
  region                                    = local.infra_outputs.region

  vpc_id             = local.infra_outputs.vpc_id
  private_subnet_ids = local.infra_outputs.private_subnet_ids
  node_port          = local.infra_outputs.k8s_node_port

  # other_latest_tag = local.infra_outputs.other_latest_tag
}
variable "terraform_role" {
  type = string
}
