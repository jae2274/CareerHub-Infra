locals {
  api_gateway_name = "${local.prefix_service_name}-gateway"

  root_path               = "/"
  root_proxy_path         = "/{proxy+}"
  backend_root_path       = "/api"
  backend_root_proxy_path = "/api/{proxy+}"
  auth_service_path       = "/auth"
  auth_service_proxy_path = "/auth/{proxy+}"

  ALL_METHODS = toset([
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "PATCH",
    "HEAD",
    "OPTIONS",
  ])
}
resource "aws_api_gateway_rest_api" "rest_api_gateway" {
  name = local.api_gateway_name

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = local.api_gateway_name
      version = "1.0"
    }

    paths = {
      "${local.root_path}" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://${local.frontend_website_endpoint}/"
          }
        }
      }
      "${local.root_proxy_path}" = {
        x-amazon-apigateway-any-method = {
          x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://${local.frontend_website_endpoint}/{proxy}"
            requestParameters = {
              "integration.request.path.proxy" = "method.request.path.proxy"
            }
          }
          parameters = [
            {
              name     = "proxy"
              in       = "path"
              required = true
              type     = "string"
            }
          ]
        }
      }
      "${local.backend_root_proxy_path}" = {
        x-amazon-apigateway-any-method = {
          x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            path                 = "proxy"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://${local.ingress_hostname}:${local.ingress_port}${local.backend_root_path}/{proxy}"
            requestParameters = {
              "integration.request.path.proxy" = "method.request.path.proxy"
            }
          }
          parameters = [
            {
              name     = "proxy",
              in       = "path",
              required = true,
              type     = "string"
            }
          ]
        }
      }
      "${local.auth_service_path}" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://${local.ingress_hostname}:${local.ingress_port}${local.auth_service_path}"
          }
        }
      }
      "${local.auth_service_proxy_path}" = {
        x-amazon-apigateway-any-method = {
          x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            path                 = "proxy"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://${local.ingress_hostname}:${local.ingress_port}${local.auth_service_path}/{proxy}"
            requestParameters = {
              "integration.request.path.proxy" = "method.request.path.proxy"
            }
          }
          parameters = [
            {
              name     = "proxy",
              in       = "path",
              required = true,
              type     = "string"
            }
          ]
        }
      }
    }
  })
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api_gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod_stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name    = "prod"


}

resource "aws_api_gateway_method_settings" "root_path_specific" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = aws_api_gateway_stage.prod_stage.stage_name
  method_path = "*/*"

  settings {
    throttling_rate_limit  = 1
    throttling_burst_limit = 1
  }
}

resource "aws_api_gateway_method_settings" "api_path_specific" {
  for_each = local.ALL_METHODS

  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = aws_api_gateway_stage.prod_stage.stage_name
  method_path = "${trimprefix(local.backend_root_proxy_path, "/")}/${each.key}"

  settings {
    throttling_rate_limit  = 5
    throttling_burst_limit = 3
  }
}
resource "aws_api_gateway_method_settings" "auth_path_specific" {
  for_each = local.ALL_METHODS

  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = aws_api_gateway_stage.prod_stage.stage_name
  method_path = "${trimprefix(local.auth_service_proxy_path, "/")}/${each.key}"

  settings {
    throttling_rate_limit  = 5
    throttling_burst_limit = 3
  }
}
# resource "aws_api_gateway_usage_plan" "usage_plan" {
#   name        = "${local.prefix_service_name}-plan"

#   description = "limits the number of requests that can be made to the API"

#   api_stages {
#     api_id = aws_api_gateway_rest_api.rest_api_gateway.id
#     stage  = aws_api_gateway_stage.prod_stage.stage_name
#   }

#   quota_settings {
#     limit  = 5
#     offset = 0
#     period = "DAY"
#   }

#   throttle_settings {
#     burst_limit = 1
#     rate_limit  = 1
#   }
# }

# resource "aws_api_gateway_domain_name" "api_gateway_domain_name" {
#   certificate_arn = aws_acm_certificate.acm_certificate.arn
#   domain_name     = local.careerhub_domain_name
# }

# resource "aws_route53_record" "route53_record" {
#   name    = aws_api_gateway_domain_name.api_gateway_domain_name.domain_name
#   type    = "A"
#   zone_id = aws_route53_zone.route53_zone.id

#   alias {
#     evaluate_target_health = true
#     name                   = aws_api_gateway_domain_name.api_gateway_domain_name.cloudfront_domain_name
#     zone_id                = aws_api_gateway_domain_name.api_gateway_domain_name.cloudfront_zone_id
#   }
# }

# resource "aws_api_gateway_base_path_mapping" "example" {
#   api_id      = aws_api_gateway_rest_api.rest_api_gateway.id
#   stage_name  = aws_api_gateway_stage.prod_stage.stage_name
#   domain_name = aws_api_gateway_domain_name.api_gateway_domain_name.domain_name
# }
