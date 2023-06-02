output "name" {
  value = aws_iam_role.sfn-iam-role.name
  description = "The name of the sfn-iam-role"
}

output "arn" {
  value = aws_iam_role.sfn-iam-role.arn
  description = "The ARN of the sfn-iam-role"
}

