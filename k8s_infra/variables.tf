locals {
  infra_outputs = data.terraform_remote_state.infra.outputs

  mongodb_user_secret_id = local.infra_outputs.mongodb_user_secret_id

  finded_history_mongodb_endpoint = local.infra_outputs.finded_history_mongodb_endpoint
  jobposting_mongodb_endpoint     = local.infra_outputs.jobposting_mongodb_endpoint
  log_mongodb_endpoint            = local.infra_outputs.log_mongodb_endpoint
  dataprovider_ecr                = local.infra_outputs.dataprovider_ecr
  dataprocessor_ecr               = local.infra_outputs.dataprocessor_ecr
  skillscanner_ecr                = local.infra_outputs.skillscanner_ecr
  logapi_ecr                      = local.infra_outputs.logapi_ecr
  region                          = local.infra_outputs.region

  node_ports        = local.infra_outputs.k8s_node_ports
  backend_root_path = "/api"

  other_latest_tag = local.infra_outputs.other_latest_tag
}
variable "terraform_role" {
  type = string
}
