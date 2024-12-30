output "service_domain" {
  value = local.service_domain
}

output "root_domain_name" {
  value = var.root_domain_name
}

output "ingress_hostname" {
  value = kubernetes_ingress_v1.ingress.status.0.load_balancer.0.ingress.0.hostname
}

output "ingress_port" {
  value = local.ingress_port
}

output "frontend_website_endpoint" {
  value = module.frontend_cicd.frontend_website_endpoint
}
