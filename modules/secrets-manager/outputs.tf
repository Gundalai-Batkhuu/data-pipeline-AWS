output "rds_password" {
  value       = aws_secretsmanager_secret_version.rds_password.secret_string
  description = "The password for the RDS database"
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_password.arn
}