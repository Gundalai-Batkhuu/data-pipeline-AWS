variable "source_repository_name" {
  type        = string
  description = "Name of the Source CodeCommit repository used by the pipeline"
}

variable "source_repository_branch" {
  type        = string
  description = "Branch of the Source CodeCommit repository used in the pipeline"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be attached to the source CodeCommit repository"
}

variable "kms_key_arn" {
  description = "Name of the project to be prefixed to create the s3 bucket"
  type        = string
}