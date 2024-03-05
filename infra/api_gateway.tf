locals {
  api_gateway_name = "${local.prefix_service_name}-gateway"
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
      "/api/{proxy+}" = {
        x-amazon-apigateway-any-method = {
          x-amazon-apigateway-integration = {
            httpMethod           = "ANY"
            path                 = "proxy"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://${local.master_ip}:${local.node_port}/{proxy}"
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
