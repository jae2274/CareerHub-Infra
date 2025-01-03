locals {
  helm_infra_outputs = data.terraform_remote_state.helm_infra.outputs

  namespace                                      = local.helm_infra_outputs.namespace
  careerhub_posting_service_helm_chart_repo      = local.helm_infra_outputs.careerhub_posting_service_helm_chart_repo
  careerhub_posting_provider_helm_chart_repo     = local.helm_infra_outputs.careerhub_posting_provider_helm_chart_repo
  careerhub_posting_skillscanner_helm_chart_repo = local.helm_infra_outputs.careerhub_posting_skillscanner_helm_chart_repo
  careerhub_userinfo_service_helm_chart_repo     = local.helm_infra_outputs.careerhub_userinfo_service_helm_chart_repo
  careerhub_api_composer_helm_chart_repo         = local.helm_infra_outputs.careerhub_api_composer_helm_chart_repo
  careerhub_review_service_helm_chart_repo       = local.helm_infra_outputs.careerhub_review_service_helm_chart_repo
  careerhub_review_crawler_helm_chart_repo       = local.helm_infra_outputs.careerhub_review_crawler_helm_chart_repo

  log_system_helm_chart_repo = local.helm_infra_outputs.log_system_helm_chart_repo


  auth_service_helm_chart_repo = local.helm_infra_outputs.auth_service_helm_chart_repo

  api_composer_service = local.helm_infra_outputs.api_composer_service
  auth_service         = local.helm_infra_outputs.auth_service

  log_system = local.helm_infra_outputs.log_system
}
