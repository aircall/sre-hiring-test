resource "aws_lambda_function" "image_resizer_lambda" {
  function_name = local.function_name
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = module.docker_image.image_uri

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.image_resize_bucket.id
    }
  }

  lifecycle {
    ignore_changes = [image_uri]
  }

  tags = local.tags

}

module "docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = local.function_name
  image_tag       = "initial"
  source_path     = "../../../"
}