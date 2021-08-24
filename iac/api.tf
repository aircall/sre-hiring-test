# API Gateway
resource "aws_api_gateway_rest_api" "default" {
  name = "${local.service_name}-api"
}

resource "aws_api_gateway_resource" "default" {
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.default.id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "default" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.default.id
  http_method   = var.http_method
  authorization = "NONE"

}

resource "aws_api_gateway_integration" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.default.id
  http_method = aws_api_gateway_method.default.http_method
  integration_http_method = var.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.default.invoke_arn
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id       = aws_api_gateway_rest_api.default.id
  stage_name        = local.stage_name
  stage_description = "Deployed at ${timestamp()}"

  depends_on = [aws_api_gateway_method.default, aws_api_gateway_integration.default]
}
resource "aws_api_gateway_usage_plan" "default" {
  name = "${local.service_name}_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.default.id
    stage  = aws_api_gateway_deployment.default.stage_name
  }
}

resource "aws_api_gateway_api_key" "default" {
  name = "${local.service_name}_key"
}

resource "aws_api_gateway_usage_plan_key" "default" {
  key_id        = aws_api_gateway_api_key.default.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}