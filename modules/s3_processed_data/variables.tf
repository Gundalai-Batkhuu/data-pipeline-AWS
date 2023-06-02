variable "lambda_iam_role_arn" {
  description = "ARN of the IAM role to be used by the project"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the codepipeline IAM role"
  type        = string
}