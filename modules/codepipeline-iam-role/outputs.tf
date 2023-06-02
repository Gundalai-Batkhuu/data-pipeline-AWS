output "arn" {
  value = aws_iam_role.codepipeline_role.arn
  description = "The ARN of the Codepipeline IAM Role"
}

output "role_name" {
  value = aws_iam_role.codepipeline_role.name
  description = "The ARN of the Codepipeline IAM Role"
}
