resource "aws_api_gateway_rest_api" "image" {
  name               = "${var.environment}-image-resizer"
  description        = "image resizer api-gateway. Includes only synthetic generation lambda endpoint"
  binary_media_types = var.binary_media_types
  endpoint_configuration {
    types = [var.api_endpoint_type]
  }

  tags = tomap({ "Name" = "${var.environment}_image_resizer" })
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "lambda_authorizer"
  rest_api_id            = aws_api_gateway_rest_api.image.id
  authorizer_uri         = aws_lambda_function.authorizer_lambda.invoke_arn
  authorizer_credentials = aws_iam_role.authorizer_invocation_role.arn
}


resource "aws_api_gateway_resource" "image_proxy" {
  parent_id   = aws_api_gateway_rest_api.image.root_resource_id
  path_part   = "image"
  rest_api_id = aws_api_gateway_rest_api.image.id
}

resource "aws_api_gateway_method" "image_post" {
  rest_api_id   = aws_api_gateway_rest_api.image.id
  resource_id   = aws_api_gateway_resource.image_proxy.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_integration" "image_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.image.id
  resource_id             = aws_api_gateway_resource.image_proxy.id
  http_method             = aws_api_gateway_method.image_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.image_resizer_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "test_deployment" {
  rest_api_id = aws_api_gateway_rest_api.image.id
  stage_name  = var.environment

  triggers = {
    dependency_change = sha1(join(",", tolist([
      jsonencode(aws_api_gateway_integration.image_post_integration),
      jsonencode(aws_lambda_function.image_resizer_lambda.invoke_arn),
      jsonencode(aws_api_gateway_authorizer.authorizer.id),
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.image_post_integration,
    aws_api_gateway_method.image_post,
    aws_api_gateway_authorizer.authorizer
  ]
}

resource "aws_lambda_permission" "image_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_resizer_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "${replace(aws_api_gateway_deployment.test_deployment.execution_arn, var.environment, "")}*/*"
}