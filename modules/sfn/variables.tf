variable "dpp-iam-role-arn" {
  default = "The ARN of the IAM role to be assumed by the DPP"
  type = string
}

variable "lambda_functions" {
  description = "List of lambda function names"
}

variable "sfn_iam_role" {
}
