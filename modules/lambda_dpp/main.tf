resource "aws_lambda_function" "lambda_sfn" {
  for_each      = toset(local.node_list)
  description = "Runs nodes of the data processing pipeline"

  function_name = each.key
  role          = var.lambda_role_arn

  image_uri = "459103101106.dkr.ecr.ap-southeast-2.amazonaws.com/dpp_step_functions_ecr:latest"

  package_type = "Image"
  timeout = 60

}

locals {
  node_list = jsondecode(file("./data-processing-pipeline/node_list.json"))
}



