resource "random_password" "api_token" {
  length  = 10
  special = false
}

resource "aws_ssm_parameter" "api_token" {
  name  = "/${var.environment}/api-token"
  type  = "SecureString"
  value = random_password.api_token.result
  tags  = merge(local.tags, tomap({ "Name" = "/${var.environment}/api-token" }))
}

resource "aws_lambda_function" "authorizer_lambda" {
  function_name = "authorizer"
  role          = aws_iam_role.lambda_authorizer_role.arn
  package_type  = "Image"
  image_uri     = module.authorizer_image.image_uri

  environment {
    variables = {
      API_TOKEN = aws_ssm_parameter.api_token.value
    }
  }

  tags = local.tags

}

module "authorizer_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo  = true
  ecr_repo         = "lambda_authorizer"
  image_tag        = "1.0"
  docker_file_path = "Dockerfile-Authorizer"
  source_path      = "../../../"
}