data "aws_iam_policy_document" "example" {
  statement {
    sid    = "EnableAnotherAWSAccountToReadTheSecret"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}