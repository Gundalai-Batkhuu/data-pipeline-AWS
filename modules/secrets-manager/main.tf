resource "random_password" "master_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "db_credentials"
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.master_password.result
}

resource "aws_secretsmanager_secret_policy" "EnableAnotherAWSAccountToReadTheSecret" {
  secret_arn = aws_secretsmanager_secret.db_password.arn
  policy     = data.aws_iam_policy_document.example.json
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-2.secretsmanager"
  vpc_endpoint_type = "Interface"
  security_group_ids = var.security_group_ids
  private_dns_enabled = true
}

resource "aws_vpc_endpoint_subnet_association" "lambda_rds_association" {
  vpc_endpoint_id = aws_vpc_endpoint.secrets_manager.id
  subnet_id       = var.vpc_subnet
}