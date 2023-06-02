variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the codepipeline IAM role"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the Lambda"
  type        = map(any)
}

variable "subnet_ids" {
  description = "The id's of the subnet of the Lambda"
  type = list(string)
}

variable "security_group_ids" {
  description = "The id's of the security group of the Lambda"
  type = list(string)
}

# Create a security group for the Lambda function to connect to the VPC
variable "vpc_id" {
}