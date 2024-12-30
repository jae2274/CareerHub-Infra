locals {
  infra_remote_state = data.terraform_remote_state.core_infra.outputs

  ingress_hostname          = local.infra_remote_state.ingress_hostname
  ingress_port              = local.infra_remote_state.ingress_port
  frontend_website_endpoint = local.infra_remote_state.frontend_website_endpoint

  root_domain_name = local.infra_remote_state.root_domain_name

  service_domain = local.infra_remote_state.service_domain
}
