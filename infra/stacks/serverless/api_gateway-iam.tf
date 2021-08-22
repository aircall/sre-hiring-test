resource "aws_iam_role" "authorizer_invocation_role" {
  name               = "api_gateway_authorizer_invocation"
  assume_role_policy = data.aws_iam_policy_document.api_gw_assume_role.json
}

resource "aws_iam_policy" "authorizer_invocation_policy" {
  name   = "authorizer_invocation_policy"
  policy = data.aws_iam_policy_document.authorizer_invocation_policy.json

  tags = local.tags
}

data "aws_iam_policy_document" "authorizer_invocation_policy" {

  statement {
    actions = ["lambda:InvokeFunction"]

    resources = ["${aws_lambda_function.authorizer_lambda.arn}"]
  }
}

resource "aws_iam_role_policy_attachment" "authorizer_invocation_policy_attachment" {
  role       = aws_iam_role.authorizer_invocation_role.name
  policy_arn = aws_iam_policy.authorizer_invocation_policy.arn
}