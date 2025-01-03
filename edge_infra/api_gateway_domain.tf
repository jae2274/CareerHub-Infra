/*
 route53과 aws_acm_certificate는 발급되기까지 시간과 절차가 필요하므로, 수동으로 미리 발급받아서 사용하도록 합니다.
  */
//********************************************************************************************************************
data "aws_route53_zone" "route53_zone" {
  name = local.root_domain_name
}

data "aws_acm_certificate" "issued" {
  domain   = "*.${local.root_domain_name}"
  statuses = ["ISSUED"]
}
//********************************************************************************************************************




resource "aws_api_gateway_domain_name" "api_gateway_domain" {
  regional_certificate_arn = data.aws_acm_certificate.issued.arn
  domain_name              = local.service_domain

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


resource "aws_route53_record" "api_gateway_record" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = aws_api_gateway_domain_name.api_gateway_domain.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api_gateway_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_domain.regional_zone_id
    evaluate_target_health = true
  }
}

resource "aws_api_gateway_base_path_mapping" "api_gateway_domain_mapping" {
  api_id      = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = aws_api_gateway_stage.prod_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api_gateway_domain.domain_name
}

resource "aws_route53_record" "log_system_hostname" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = local.log_hostname
  type    = "CNAME"
  ttl     = 300

  records = [local.ingress_hostname]
}
