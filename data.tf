data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [aws_default_vpc.default.id]
  }
}