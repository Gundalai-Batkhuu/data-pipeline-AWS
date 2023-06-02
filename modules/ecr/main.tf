resource "aws_ecr_repository" "dpp_step_functions_ecr_repo" {
  name                 = "dpp_step_functions_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_repository_policy" "foopolicy" {
  repository = aws_ecr_repository.dpp_step_functions_ecr_repo.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}



