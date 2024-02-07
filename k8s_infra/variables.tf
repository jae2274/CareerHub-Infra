locals {
  infra_outputs = data.terraform_remote_state.infra.outputs

  jobposting_mongodb_endpoint = local.infra_outputs.jobposting_mongodb_endpoint
  log_mongodb_endpoint        = local.infra_outputs.log_mongodb_endpoint
  dataprovider_ecr            = local.infra_outputs.dataprovider_ecr
  dataprocessor_ecr           = local.infra_outputs.dataprocessor_ecr
  logapi_ecr                  = local.infra_outputs.logapi_ecr

  other_latest_tag = local.infra_outputs.other_latest_tag
}
