resource "aws_iam_role" "lambda_role" {
  name = var.lambda_iam_role_name
  tags = var.tags
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
}


resource "aws_iam_policy" "lambda_basic_exec" {
  name = "AWSLambdaBasicExecutionRole_policy"
  path = "/Lambda/"
  policy = data.aws_iam_policy_document.AWSLambdaBasicExecutionRole.json
}


resource "aws_iam_role_policy_attachment" "lambda_basic_exec_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_basic_exec.arn
}


resource "aws_iam_policy" "lambda_vpc" {
  name = "AWSLambdaVPCAccessExecutionRole_policy"
  path = "/Lambda/"
  policy = data.aws_iam_policy_document.AWSLambdaVPCAccessExecutionRole.json
}


resource "aws_iam_role_policy_attachment" "lambda_vpc_attachment" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_vpc.arn
}


resource "aws_iam_policy" "lambda_sqs" {
  name = "AWSLambdaSQSQueueExecutionRole_policy"
  path = "/Lambda/"
  policy = data.aws_iam_policy_document.AWSLambdaSQSQueueExecutionRole.json
}


resource "aws_iam_role_policy_attachment" "lambda_sqs_attachment" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs.arn
}


resource "aws_iam_policy" "lambda_secrets_manager" {
  name = "AWSLambdaSecretsManagerExecutionRole_policy"
  path = "/Lambda/"
  policy = data.aws_iam_policy_document.AWSLambdaSecretsManagerAccess.json
}


resource "aws_iam_role_policy_attachment" "lambda_secrets_manager_attachment" {
  policy_arn = aws_iam_policy.lambda_secrets_manager.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "lambda_s3" {
  name = "AmazonS3FullAccess_policy"
  path = "/Lambda/"
  policy = data.aws_iam_policy_document.AmazonS3FullAccess.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attachment" {
  policy_arn = aws_iam_policy.lambda_s3.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "lambda_step_functions" {
  policy = data.aws_iam_policy_document.step_functions_policy.json
  name = "lambda_step_functions"
  path = "/Lambda/"
}

resource "aws_iam_role_policy_attachment" "step_function_attachment" {
  policy_arn = aws_iam_policy.lambda_step_functions.arn
  role       = aws_iam_role.lambda_role.name
}