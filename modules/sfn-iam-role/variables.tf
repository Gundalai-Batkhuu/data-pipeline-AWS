variable "dpp-lambda-arn" {
  default = "The ARN of the DPP Lambda function"
    type = string
}

variable "sfn_arn" {
  default = "ARN of the DPP State Machine"
    type = string
}

variable "lambda_functions" {
  description = "List of lambda function names"
}

