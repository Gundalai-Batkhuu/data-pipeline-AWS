data "aws_iam_policy_document" "ecr_push_policy" {
    statement {
        sid = "AllowPushPull"

        actions = [
        "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]

        resources = [
        var.ecr_repository_arn
        ]
    }
}

