output "id" {
  value       = aws_lambda_function.trigger_step_function_lambda.id
  description = "The id of the Lambda function"
}

output "name" {
  value       = aws_lambda_function.trigger_step_function_lambda.function_name
  description = "The function name of the Lambda function"
}

output "arn" {
  value       = aws_lambda_function.trigger_step_function_lambda.arn
  description = "The arn of the Lambda function"
}


