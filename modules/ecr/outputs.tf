output "name" {
  value       = aws_ecr_repository.dpp_step_functions_ecr_repo.name
  description = "The name of the ecr repository"
}

output "arn" {
  value       = aws_ecr_repository.dpp_step_functions_ecr_repo.arn
  description = "The ARN of the ecr repository"
}