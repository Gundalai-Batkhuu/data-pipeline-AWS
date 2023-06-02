# Declares the managed policy that allows the role to interact with an AWS Step Functions state machine
data "aws_iam_policy_document" "sfn_policy" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution",
      "states:StopExecution",
      "states:DescribeExecution",
      "states:ListExecutions",
      "states:ListStateMachines",
      "states:ListActivities",
      "states:GetExecutionHistory",
      "states:SendTaskSuccess",
      "states:SendTaskFailure",
      "states:SendTaskHeartbeat",
      "states:DeleteStateMachine",
      "states:DescribeStateMachine"
    ]
    resources = [var.sfn_arn]
  }
}


data "aws_iam_policy_document" "sfn_lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}



