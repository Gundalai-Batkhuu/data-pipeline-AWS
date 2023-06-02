resource "aws_iam_role" "codepipeline_role" {
  name = var.codepipeline_iam_role_name
  tags = var.tags
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  path               = "/"
}


resource "aws_iam_policy" "codepipeline_policy" {
  name        = "codepipeline-policy"
  description = "Policy to allow codepipeline to execute"
  tags        = var.tags
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
         "rds:CreateDBInstance",
         "rds:DescribeDBInstances"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
         "kms:DescribeKey",
         "kms:GenerateDataKey*",
         "kms:Encrypt",
         "kms:ReEncrypt*",
         "kms:Decrypt"
      ],
      "Resource": "${var.kms_key_arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:BatchGetProjects"
      ],
      "Resource": "arn:aws:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:project/${var.project_name}*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:CreateReportGroup",
        "codebuild:CreateReport",
        "codebuild:UpdateReport",
        "codebuild:BatchPutTestCases"
      ],
      "Resource": "arn:aws:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:report-group/${var.project_name}*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}


resource "aws_iam_policy" "RDSPolicy" {
  name        = "RDSPolicy"
  path = "/codepipeline/"
  policy = data.aws_iam_policy_document.RDSPolicy.json
}


resource "aws_iam_role_policy_attachment" "RDSPolicy" {
  role      = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.RDSPolicy.arn
}


resource "aws_iam_policy" "IAMRolePolicy" {
  name = "IAMRolePolicy"
  path = "/codepipeline/"
  policy = data.aws_iam_policy_document.IAMRolePolicy.json
}


resource "aws_iam_role_policy_attachment" "IAMRolePolicy" {
  role = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.IAMRolePolicy.arn
}


resource "aws_iam_policy" "CodeCommitPolicy" {
  name = "CodeCommitPolicy"
  path = "/codepipeline/"
  policy = data.aws_iam_policy_document.CodeCommitPolicy.json
}


resource "aws_iam_role_policy_attachment" "CodeCommitPolicy" {
  role = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.CodeCommitPolicy.arn
}


resource "aws_iam_policy" "LambdaPolicy" {
  name = "LambdaPolicy"
  path      = "/codepipeline/"
  policy = data.aws_iam_policy_document.LambdaPolicy.json
}


resource "aws_iam_role_policy_attachment" "LambdaPolicy" {
  role = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.LambdaPolicy.arn
}


resource "aws_iam_policy" "S3Policy" {
  name = "S3Policy"
  path = "/codepipeline/"
  policy = data.aws_iam_policy_document.S3Policy.json
}


resource "aws_iam_role_policy_attachment" "S3Policy" {
  role = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.S3Policy.arn
}


resource "aws_iam_policy" "CodePipelinePolicy" {
  name = "CodePipelinePolicy"
    path = "/codepipeline/"
  policy = data.aws_iam_policy_document.CodePipelinePolicy.json
}


resource "aws_iam_role_policy_attachment" "CodePipelinePolicy" {
  role = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.CodePipelinePolicy.arn
}


resource "aws_iam_policy" "sfn_policy_for_codepipeline" {
  name = "sfn_policy_for_codepipeline"
  path = "/sfn/"
  policy = data.aws_iam_policy_document.sfnPolicy.json
}


resource "aws_iam_role_policy_attachment" "sfn_policy_attachment" {
  policy_arn = aws_iam_policy.sfn_policy_for_codepipeline.arn
  role       = aws_iam_role.codepipeline_role.name
}


resource "aws_iam_policy" "ecr_policy" {
  name = "ecr_policy_for_codepipeline"
  path = "/ecr/"
  policy = data.aws_iam_policy_document.ECRPolicy.json
}


resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  policy_arn = aws_iam_policy.ecr_policy.arn
  role       = aws_iam_role.codepipeline_role.name
}


