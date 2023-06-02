/*

output "lambda_functions" {
  description = "The ARN of the Lambda functions"
  value       = aws_lambda_function.lambda_sfn[test-extract-tables-node].arn
}

output "lambda_functions" {
  description = "The ARN of the Lambda functions"
  value = aws_lambda_function.lambda_sfn[*]
}

output "lambda_functions" {
  description = "The ARN of the Lambda functions"
  value       = { for key in keys(aws_lambda_function.lambda_sfn) : key => aws_lambda_function.lambda_sfn[key].arn }
}

*/


output "lambda_functions" {
  description = "The names and ARNs of the created Lambda functions"
  value = {
    for k, v in aws_lambda_function.lambda_sfn : k => {
      arn = v.arn
    }
  }
}
