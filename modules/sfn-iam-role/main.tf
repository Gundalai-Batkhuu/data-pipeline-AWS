resource "aws_iam_role" "sfn-iam-role" {
  name = "sfn-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "lambda_policy" {
  name = "sfn_lambda_policy"
  path = "/sfn/"
  policy = data.aws_iam_policy_document.sfn_lambda_policy.json
}


resource "aws_iam_role_policy_attachment" "sfn_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.sfn-iam-role.name
}


resource "aws_iam_policy" "sfn_policy" {
  name = "sfn_policy"
  path = "/sfn/"
  policy = data.aws_iam_policy_document.sfn_policy.json
}

resource "aws_iam_role_policy_attachment" "sfn_policy" {
  policy_arn = aws_iam_policy.sfn_policy.arn
  role       = aws_iam_role.sfn-iam-role.name
}
