resource "aws_lambda_function" "authorizer_lambda" {
  function_name = "authorizer"
  role          = aws_iam_role.lambda_authorizer_role.arn
  package_type  = "Image"
  image_uri     = module.authorizer_image.image_uri

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.image_resize_bucket.id
    }
  }

  tags = local.tags

}

module "authorizer_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo  = true
  ecr_repo         = "lambda_authorizer"
  image_tag        = "1.2"
  docker_file_path = "Dockerfile-Authorizer"
  source_path      = "../../../"
}