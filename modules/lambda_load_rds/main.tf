resource "aws_lambda_function" "load_rds_lambda" {
  function_name = "load_rds_lambda"
  description = "Loads data into a relational database"
  role = var.lambda_role_arn
  tags  = var.tags

  filename      = "lambda-content/load-rds-function/deployment-package.zip"
  handler       = "lambda_function.lambda_handler"
  source_code_hash = "data.archive_file.output_base64sha256"
  runtime       = "python3.8"
  layers = ["arn:aws:lambda:ap-southeast-2:336392948345:layer:AWSSDKPandas-Python38:5", "arn:aws:lambda:ap-southeast-2:898466741470:layer:psycopg2-py38:1"]
  memory_size = 512
  timeout = 120

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Security group for the Lambda function to connect to the VPC"
  vpc_id      = var.vpc_id
}


