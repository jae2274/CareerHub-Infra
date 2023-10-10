

locals {
  lambda = {
    function_name = "${local.prefix}jobposting_provider"
  }
}



module "lambda_function_existing_package_local" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.0.0"

  function_name = local.lambda.function_name
  runtime = "java17"
  handler = "org.springframework.cloud.function.adapter.aws.FunctionInvoker::handleRequest"

  create_package = false
  ignore_source_code_hash = true
  local_existing_package = "${path.module}/deploy_lambda.jar"
  timeout = 15
  memory_size = 512
  environment_variables = {
    FUNCTION_NAME = "callLambda"
    SPRING_PROFILES_ACTIVE = "aws"
    jasyptPassword = "rM5zjyl09gtYucJ"
  }
  tags = {
    monitoring = "false"
    env = local.branch
  }



  cloudwatch_logs_retention_in_days = 3
}