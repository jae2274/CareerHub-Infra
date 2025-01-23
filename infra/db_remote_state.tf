locals {
  db_infra_outputs = data.terraform_remote_state.db_infra.outputs

  mongodb_project_id = local.db_infra_outputs.mongodb_project_id

  jobposting_mongodb_endpoint = local.db_infra_outputs.jobposting_mongodb_endpoint
  userinfo_mongodb_endpoint   = local.db_infra_outputs.userinfo_mongodb_endpoint
  review_mongodb_endpoint     = local.db_infra_outputs.review_mongodb_endpoint

  mongodb_username_secret_id = local.db_infra_outputs.mongodb_username_secret_id
  mongodb_password_secret_id = local.db_infra_outputs.mongodb_password_secret_id
}
