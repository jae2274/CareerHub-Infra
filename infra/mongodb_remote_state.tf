locals {
  mongodb_remote_state = data.terraform_remote_state.mongodb_infra.outputs


  jobposting_db_private_endpoint_secret_id = local.mongodb_remote_state.jobposting_db_endpoint_secret_id
  review_db_private_endpoint_secret_id     = local.mongodb_remote_state.review_db_endpoint_secret_id
  userinfo_db_private_endpoint_secret_id   = local.mongodb_remote_state.userinfo_db_endpoint_secret_id

  mongodb_username_secret_id = local.mongodb_remote_state.mongodb_username_secret_id
  mongodb_password_secret_id = local.mongodb_remote_state.mongodb_password_secret_id
}
