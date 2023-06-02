# Assume Role policy that allows the Lambda service to assume the role.
data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com",
                      "states.amazonaws.com"
      ]
    }
  }
}

# Declares the the managed policy that allows using CloudWatch Logs for Lambda
data "aws_iam_policy_document" "AWSLambdaBasicExecutionRole" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "iam:GetPolicyVersion"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# Declares the managed policy that allows Lambda to access a resource within a VPC - create, describe, delete network interfaces, and write permissions to CloudWatch logs.
data "aws_iam_policy_document" "AWSLambdaVPCAccessExecutionRole" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "iam:GetPolicyVersion",
      "lambda:GetLayerVersion",
      "lambda:InvokeFunction"

    ]
    resources = ["*"]
  }
}

# Declares the managed policy that provides receive message, delete message, and read attribute access to SQS queues, and write permissions to CloudWatch logs.
data "aws_iam_policy_document" "AWSLambdaSQSQueueExecutionRole" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "iam:GetPolicyVersion",
      "logs:PutLogEvents"
    ]
    resources = ["*", "arn:aws:logs:*:*:*"]
  }
}

# Declares the managed policy that allows the role to get iam role
data "aws_iam_policy_document" "AWSLambdaIAMGetRole" {
  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:GetPolicyVersion"
    ]
    resources = ["*"]
  }
}

# Allow access to Secrets Manager for Lambda function

data  "aws_iam_policy_document" "AWSLambdaSecretsManagerAccess" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "AmazonS3FullAccess" {
    statement {
        effect = "Allow"
        actions = [
        "s3:GetObject*",
        "s3:GetBucket*",
        "s3:List*",
        "s3:DeleteObject*",
        "s3:PutObject*",
        "s3:Abort*"
        ]
        resources = [var.processed_s3_arn, "arn:aws:s3:::processed-data-7374046/*", var.intermediate_s3_arn, var.raw_s3_arn, var.validated_s3_arn]
    }
}


data "aws_iam_policy_document" "step_functions_policy" {
    statement {
        effect = "Allow"
        actions = [
        "states:StartExecution"
        ]
        resources = ["arn:aws:states:ap-southeast-2:459103101106:stateMachine:dpp_state_machine"]
    }
}

