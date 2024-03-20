locals {
  api_gateway_name  = "${local.prefix_service_name}-gateway"
  user_service_path = "/auth"
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
      "/" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://${local.frontend_website_endpoint}/"
          }
        }
      }
      "/{proxy+}" = {
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
      "${local.backend_root_path}/{proxy+}" = {
        x-amazon-apigateway-any-method = {
          x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            path                 = "proxy"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://${local.master_ip}:${local.careerhub_node_port}/{proxy}"
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
      "${local.user_service_path}" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://${local.master_ip}:${local.user_service_node_port}${local.user_service_path}"
          }
        }
      }
      "${local.user_service_path}/{proxy+}" = {
        x-amazon-apigateway-any-method = {
          x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            path                 = "proxy"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://${local.master_ip}:${local.user_service_node_port}${local.user_service_path}/{proxy}"
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
