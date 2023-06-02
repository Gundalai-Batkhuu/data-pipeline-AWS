resource "aws_codecommit_repository" "Data-preparation-pipeline" {
  repository_name = var.source_repository_name
  default_branch  = var.source_repository_branch
  description     = "Shine Solutions internship project of Gundalai Batkhuu during the ANU Semester 1 2023. Code Repository for hosting the terraform code and pipeline configuration files"
  tags            = var.tags
}
