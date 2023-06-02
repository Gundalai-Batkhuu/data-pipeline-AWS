data "aws_iam_policy_document" "AWSS3TrustPolicy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    sid = ""
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "s3Policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.codepipeline_role_arn, var.lambda_iam_role_arn]
    }
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:ReplicateObject",
      "s3:PutObject",
      "s3:RestoreObject",
      "s3:PutObjectVersionTagging",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl",
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.raw_data_bucket.arn,
      "${aws_s3_bucket.raw_data_bucket.arn}/*"
    ]
  }
}



