resource "aws_s3_bucket" "validated_data_bucket" {
  bucket = "validated-data-7374046"
  tags = var.tags
}


resource "aws_iam_role" "s3_validated_data_role" {
  name = "s3_validated_data_role"
  assume_role_policy = data.aws_iam_policy_document.AWSS3TrustPolicy.json
}


resource "aws_lambda_permission" "AllowExecutionFromS3Bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.validated_data_bucket.arn
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.validated_data_bucket.id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.AllowExecutionFromS3Bucket]
}


resource "aws_s3_bucket_policy" "bucket_policy_codepipeline_bucket" {
  bucket = aws_s3_bucket.validated_data_bucket.id
  policy = data.aws_iam_policy_document.s3Policy.json
}

resource "aws_vpc_endpoint" "s3_processed_data" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [var.route_table_id]
}


resource "aws_route_table_association" "a" {

  subnet_id      = var.vpc_subnet
  route_table_id = var.route_table_id
}




