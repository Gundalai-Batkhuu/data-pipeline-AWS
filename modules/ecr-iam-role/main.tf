resource "aws_iam_role" "ecr_push_role" {
  name = "ecr_push_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "ecr_push_policy" {
  name        = "ecr_push_policy"
  path = "/ecr/"
  policy = data.aws_iam_policy_document.ecr_push_policy.json
}


resource "aws_iam_role_policy_attachment" "ecr_push_policy" {
    role       = aws_iam_role.ecr_push_role.name
    policy_arn = aws_iam_policy.ecr_push_policy.arn
}