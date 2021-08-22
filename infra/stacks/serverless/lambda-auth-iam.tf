resource "aws_iam_role" "lambda_authorizer_role" {
  name               = "lambda_authorizer-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.tags
}

resource "aws_iam_policy" "lambda_authorizer_iam_policy" {
  name   = "lambda_authorizer_iam_policy"
  policy = data.aws_iam_policy_document.lambda_authorizer_iam_policy.json

  tags = local.tags
}

data "aws_iam_policy_document" "lambda_authorizer_iam_policy" {

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_authorizer_iam_policy_attachment" {
  role       = aws_iam_role.lambda_authorizer_role.name
  policy_arn = aws_iam_policy.lambda_authorizer_iam_policy.arn
}