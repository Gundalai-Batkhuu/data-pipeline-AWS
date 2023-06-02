data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# Identity-based policy allow ListTagsForResource action on the RDS resource
data "aws_iam_policy_document" "RDSPolicy" {
  statement {
    effect = "Allow"
    actions = [
      "rds:ListTagsForResource"
    ]
    resources = [var.rds_arn]
  }
}

# IAM policies for the role
data "aws_iam_policy_document" "IAMRolePolicy" {
  statement {
    effect = "Allow"
    actions = [
       "iam:TagRole",
       "iam:CreateRole",
       "iam:CreatePolicy",
       "iam:GetRole",
       "iam:GetPolicy",
       "iam:DeletePolicy",
       "iam:GetPolicyVersion",
       "iam:ListRolePolicies",
       "iam:ListAttachedRolePolicies",
       "iam:ListPolicyVersions",
       "iam:DetachRolePolicy",
       "iam:CreatePolicyVersion",
       "iam:DeletePolicyVersion"
    ]
    resources = ["*"]
  }
}


# CodeCommit policies for the role
data "aws_iam_policy_document" "CodeCommitPolicy" {
statement {
    effect  = "Allow"
    actions = [
       "codecommit:GitPull",
       "codecommit:GitPush",
       "codecommit:GetBranch",
       "codecommit:CreateCommit",
       "codecommit:ListRepositories",
       "codecommit:BatchGetCommits",
       "codecommit:BatchGetRepositories",
       "codecommit:GetCommit",
       "codecommit:GetRepository",
       "codecommit:GetUploadArchiveStatus",
       "codecommit:ListBranches",
       "codecommit:ListTagsForResource",
       "codecommit:UploadArchive"
    ]
    resources = [var.source_repository_arn]
  }
}



data "aws_iam_policy_document" "LambdaPolicy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:GetFunction",
      "lambda:ListVersionsByFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:GetPolicy",
      "lambda:UpdateFunctionCode",
      "lambda:DeleteFunction"
    ]
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "S3Policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketPolicy",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:CreateBucket"
    ]
    resources = [var.s3_artifacts_bucket_arn, var.s3_raw_bucket_arn, "arn:aws:s3:::terraform-state-bucket-123456", "arn:aws:s3:::terraform-state-bucket-123456/*"]
  }
}


data "aws_iam_policy_document" "CodePipelinePolicy" {
  statement {
    effect = "Allow"
    actions = [
      "codepipeline:GetPipeline",
      "codepipeline:ListTagsForResource"
    ]
    resources = [var.codepipeline_arn]
  }
}


data "aws_iam_policy_document" "ECRPolicy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:ListTagsForResource"
    ]
    resources = [var.ecr_repo_arn]
  }
}


data "aws_iam_policy_document" "sfnPolicy" {
  statement {
    effect = "Allow"
    actions = [
      "states:CreateStateMachine",
      "states:DeleteStateMachine",
      "states:DescribeStateMachine",
      "states:CreateActivity",
      "states:DeleteActivity",
      "states:UpdateActivity",
      "states:DescribeActivity",
      "states:ListTagsForResource"
    ]
    resources = [var.sfn_arn, "arn:aws:states:*:*:activity:*"]
  }
}

