output "arn" {
  value = aws_iam_role.lambda_role.arn
  description = "The ARN of the Lambda IAM Role"
}

output "role_name" {
  value = aws_iam_role.lambda_role.name
  description = "The ARN of the Lambda IAM Role"
}
