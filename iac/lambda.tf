resource "aws_lambda_layer_version" "layer" {
  layer_name          = local.service_name
  compatible_runtimes = [var.runtime]
  filename            = local.filename_module
  source_code_hash    = base64sha256(local.filename_module)
}

resource "aws_lambda_function" "default" {
  function_name    = "${local.service_name}-lambda"
  description      = "Lambda application -  ${local.service_name}"
  role             = aws_iam_role.default.arn
  handler          = "app.lambdaHandler"
  publish          = true
  runtime          = var.runtime
  filename         = local.filename_codebase
  source_code_hash = base64sha256(local.filename_codebase)
  memory_size      = 512
  timeout          = 600

  layers = [
    aws_lambda_layer_version.layer.arn
  ]

  environment {
    variables = {
      S3_BUCKET = "${local.service_name}-bucket"
    }
  }

  tags = {
    owner        = local.owner
    service_name = local.service_name
    managed_by   = local.managed_by
    envname      = local.envname
    versioning   = local.versioning
  }
}

resource "aws_lambda_permission" "default" {
  function_name = aws_lambda_function.default.function_name
  action        = "lambda:InvokeFunction"
  statement_id  = "AllowExecutionFromAPIGateway"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_iam_role" "default" {
  name = "${local.service_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${local.service_name}-bucket/*",
    ]
  }
}

resource "aws_iam_policy" "default" {
  name   = "${local.service_name}-policy"
  policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}
