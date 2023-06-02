resource "aws_s3_bucket" "raw_data_bucket" {
  bucket = "raw-data-7374046"
}


resource "aws_iam_role" "s3_raw_data_role" {
  name = "s3_raw_data_role"
  assume_role_policy = data.aws_iam_policy_document.AWSS3TrustPolicy.json
}


resource "aws_lambda_permission" "AllowExecutionFromS3Bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data_bucket.arn
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.raw_data_bucket.id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.AllowExecutionFromS3Bucket]
}


resource "aws_s3_bucket_policy" "bucket_policy_codepipeline_bucket" {
  bucket = aws_s3_bucket.raw_data_bucket.id
  policy = data.aws_iam_policy_document.s3Policy.json
}









