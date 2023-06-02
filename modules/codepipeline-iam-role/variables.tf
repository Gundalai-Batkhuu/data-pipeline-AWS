variable "source_repository_name" {
  type        = string
  description = "Name of the Source CodeCommit repository"
}

variable "source_repository_arn" {
  description = "Arn of the Source CodeCommit repository"
  type        = string
}

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "codepipeline_iam_role_name" {
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

variable "s3_artifacts_bucket_arn" {
  description = "The ARN of the S3 Bucket containing the CodePipeline artifacts"
  type        = string
}

variable "s3_raw_bucket_arn" {
  description = "The ARN of the S3 Bucket containing the raw data"
  type        = string
}

variable "s3_dpp_bucket_arn" {
  default = "The ARN of the S3 Bucket containing the DPP data"
    type        = string
}

variable "rds_arn" {
  description = "The ARN of the S3 Bucket containing the raw data"
  type        = string
}


variable "lambda_raw_data_ingestion_arn" {
  description = "The ARN of the raw_data_ingestion Lambda function"
  type        = string
}


variable "codepipeline_arn" {
    description = "The ARN of the CodePipeline"
    type        = string
}


variable "ecr_repo_arn" {
    description = "The ARN of the ECR repository"
    type        = string
}


variable "sfn_arn" {
  description = "The ARN of the Step Function"
    type        = string
}
