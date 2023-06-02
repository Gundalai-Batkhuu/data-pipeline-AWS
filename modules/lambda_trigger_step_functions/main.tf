resource "aws_lambda_function" "trigger_step_function_lambda" {
  function_name = "trigger_step_function_lambda"
  description = "Triggers the step functions state machine"
  role = var.lambda_role_arn
  filename      = "lambda-content/trigger-step-function/my-deployment-package.zip"
  handler       = "lambda_function.lambda_handler"
  source_code_hash = "data.archive_file.output_base64sha256"
  runtime       = "python3.8"
  memory_size = 512
  timeout = 120
}



