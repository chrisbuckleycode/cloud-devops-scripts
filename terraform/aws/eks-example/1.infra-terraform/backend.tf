terraform {
  backend "s3" {
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "terraform-remote-state-8yuf7dsy87dsfyg"
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_encryption" {
  bucket = aws_s3_bucket.state_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_dynamodb_table" "state_lock" {
  hash_key = "LockID"
  name = "state_lock"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}
