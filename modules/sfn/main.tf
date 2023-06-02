resource "aws_sfn_state_machine" "dpp_state_machine" {
  name = "dpp_state_machine"
  role_arn = var.sfn_iam_role

  definition = local.sfn_definition_json
}

locals {
  sfn_definition_json = file("./data-processing-pipeline/sfn_definition.json")
}




/*
resource "aws_sfn_state_machine" "dpp_state_machine" {
  name = "dpp_state_machine"
  role_arn = var.dpp-iam-role-arn

  definition = local.state_machine_definition
}

locals {
  state_machine_definition = <<EOF
  {
    "Comment": "State Machine definition for the Kedro pipeline nodes",
    "StartAt": "Start",
    "States": {
      "Start": {
      "Type": "Pass",
      "Next": "${var.clean_node_names[0]}"
      },
      "${var.clean_node_names[0]}": {
        "Retry": [
                {
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": "${var.lambda_functions[var.clean_node_names[0]]["arn"]}",
          "Payload": {
            "node_name": "${var.node_names[0]}"
          }
        },
        "Next": "${var.clean_node_names[1]}"
      },

      "${var.clean_node_names[1]}": {
        "Retry": [
                {
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": "${var.lambda_functions[var.clean_node_names[1]]["arn"]}",
          "Payload": {
            "node_name": "${var.node_names[1]}"
          }
        },
        "End": true
      }
    }
  }
  EOF
  }

*/
