resource "aws_db_instance" "data_store" {
  tags = var.tags
  allocated_storage    = 10
  max_allocated_storage = 20
  db_name              = "data_store"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  username             = "gundalai"
  password             = var.rds_password
  skip_final_snapshot  = true
  backup_retention_period = 0
  apply_immediately = true
}






