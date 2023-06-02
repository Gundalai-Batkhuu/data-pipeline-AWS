variable "project_name" {
  description = "Name of the project to be prefixed to create the s3 bucket"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the IAM Role"
  type        = map(any)
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function"
  type = string
}

variable "lambda_iam_role_name" {
  description = "Name of the IAM role to be used by the project"
  type        = string
}

variable "lambda_iam_role_arn" {
  description = "ARN of the IAM role to be used by the project"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the data processing Lambda function"
  type = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the codepipeline IAM role"
  type        = string
}

variable "vpc_id" {
}

variable "security_group_ids" {
}

variable "vpc_subnet" {
}

# Create a Gateway Endpoint for S3
variable "route_table_id" {
}