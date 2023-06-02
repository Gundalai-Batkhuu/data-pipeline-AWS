variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "lambda_iam_role_name" {
  description = "Name of the IAM role to be used by the project"
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

variable "secret_arn" {
}

variable "processed_s3_arn" {
}

variable "intermediate_s3_arn" {
}

variable "raw_s3_arn" {
}

variable "validated_s3_arn" {
}
