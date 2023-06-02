output "clone_url_http" {
  value       = aws_codecommit_repository.Data-preparation-pipeline.clone_url_http
  description = "List containing the clone url of the CodeCommit repositories"
}

output "repository_name" {
  value       = aws_codecommit_repository.Data-preparation-pipeline.repository_name
  description = "The name of the CodeCommit repository"
}

output "arn" {
  value       = aws_codecommit_repository.Data-preparation-pipeline.arn
  description = "LList containing the arn of the CodeCommit repositories"
}
