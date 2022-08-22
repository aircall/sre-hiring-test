resource "aws_iam_role" "this" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "this" {
  name        = "lambda_permissions"
  path        = "/"
  description = "IAM policy for a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "s3:*"
      ],
      "Resource": ["arn:aws:s3:::aircall-${local.env}/*"],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_ecr_repository" "this" {
  name                 = "node-lambda"
}

resource "aws_ecr_registry_policy" "this" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          "AWS" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "ecr:ReplicateImage"
        ],
        Resource = [
          "arn:${data.aws_partition.current.partition}:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
        ]
      }
    ]
  })
}

resource "null_resource" "this" {
  provisioner "local-exec" {
    command = <<EOF
    docker build -t ${aws_ecr_repository.this.repository_url}:${var.image_tag} -f ../Dockerfile ../.
    docker push ${aws_ecr_repository.this.repository_url}:${var.image_tag}
    EOF
  }
}

resource "aws_lambda_function" "this" {
  image_uri     = "${aws_ecr_repository.this.repository_url}:${var.image_tag}"
  function_name = "aircall-${local.env}"
  role          = aws_iam_role.this.arn
  timeout       = 180
  package_type  = "Image"
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      S3_BUCKET = "aircall-${local.env}"
    }
  }
  tags = local.common_tags
  depends_on = [null_resource.this]
}

resource "aws_lambda_function_url" "this" {
  function_name      = aws_lambda_function.this.arn
  authorization_type = "NONE"
  cors {
    allow_methods = ["POST"]
    allow_origins = ["*"]
  }
}

resource "aws_s3_bucket" "this" {
  bucket = "aircall-${local.env}"
  tags   = local.common_tags
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "public-read"
}

module "cloudfront" {
  source                 = "cloudposse/cloudfront-cdn/aws"
  version                = "v0.24.1"
  distribution_enabled   = true
  origin_domain_name     = replace(replace(aws_lambda_function_url.this.function_url, "https://", ""), "/", "")
  name                   = "aircall-${local.env}"
  compress               = false
  viewer_protocol_policy = "redirect-to-https"
  default_root_object    = ""
  price_class            = "PriceClass_All"
  forward_cookies        = "all"
  forward_query_string   = true
  logging_enabled        = false
  min_ttl                = 0
  default_ttl            = 3600
  max_ttl                = 86400
  tags                   = local.common_tags
}