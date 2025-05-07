locals {
  api_gateway_name = "${local.prefix_service_name}-gateway"

  root_path               = "/"
  root_proxy_path         = "/{proxy+}"
  backend_root_proxy_path = "${local.backend_root_path}/{proxy+}"
  auth_service_path       = "/auth"
  auth_service_proxy_path = "${local.auth_service_path}/{proxy+}"

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
            uri                  = "http://${var.master_public_ip}:${var.careerhub_node_port}/{proxy}"
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
            uri                  = "http://${var.master_public_ip}:${var.auth_service_node_port}${local.auth_service_path}"
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
            uri                  = "http://${var.master_public_ip}:${var.auth_service_node_port}${local.auth_service_path}/{proxy}"
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
    throttling_rate_limit  = 5
    throttling_burst_limit = 5
  }
}

resource "aws_api_gateway_method_settings" "api_path_specific" {
  for_each = local.ALL_METHODS

  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = aws_api_gateway_stage.prod_stage.stage_name
  method_path = "${trimprefix(local.backend_root_proxy_path, "/")}/${each.key}"

  settings {
    throttling_rate_limit  = 25
    throttling_burst_limit = 15
  }
}

resource "aws_api_gateway_method_settings" "auth_path_specific" {
  for_each = local.ALL_METHODS

  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = aws_api_gateway_stage.prod_stage.stage_name
  method_path = "${trimprefix(local.auth_service_proxy_path, "/")}/${each.key}"

  settings {
    throttling_rate_limit  = 25
    throttling_burst_limit = 15
  }
}
