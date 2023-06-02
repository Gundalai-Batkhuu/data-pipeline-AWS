resource "aws_s3_bucket" "processed_data_bucket" {
  bucket = "processed-data-7374046"
}

resource "aws_iam_role" "s3_processed_data_role" {
  name = "s3_processed_data_role"
  assume_role_policy = data.aws_iam_policy_document.AWSS3TrustPolicy.json
}

resource "aws_s3_bucket_policy" "bucket_policy_codepipeline_bucket" {
  bucket = aws_s3_bucket.processed_data_bucket.id
  policy = data.aws_iam_policy_document.s3Policy.json
}


