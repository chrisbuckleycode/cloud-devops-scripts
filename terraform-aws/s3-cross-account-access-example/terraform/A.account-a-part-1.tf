# - Account A: User
# - Account A: S3 bucket
# - Account A: Bucket policy denying insecure traffic
# - Account A: Bind above policy to bucket
# - Account A: Identity policy allow access to bucket
# - Account A: Bind above policy to user
# -----------------------------------------------------------

# - Account A: User
resource "aws_iam_user" "user_account_a" {
  name = "user_account_a"
}

# - Account A: S3 bucket
resource "aws_s3_bucket" "bucket_account_a" {
  bucket = "bucket-account-a-f73gd7s6"
}

resource "aws_s3_bucket_public_access_block" "bucket_account_a_block_public_access" {
  bucket = aws_s3_bucket.bucket_account_a.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# - optional. An example of extra bucket configuration
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_30_days_bucket_a" {
  bucket = aws_s3_bucket.bucket_account_a.id
  rule {
    status = "Enabled"
    id     = "expire_all_files"
    expiration {
        days = 30
    }
  }
}

# - Account A: Bucket policy denying insecure traffic
# - Account A: Bind above policy to bucket
# Using 'jsonencode' method
resource "aws_s3_bucket_policy" "bucket_policy_bucket_a_https_only" {
  bucket = aws_s3_bucket.bucket_account_a.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = ""
    Statement = [
      {
        Sid       = ""
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.bucket_account_a.arn,
          "${aws_s3_bucket.bucket_account_a.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

# - Account A: Identity policy allow access to bucket
# - Account A: Bind above policy to user
# Alternative way to state policy using 'EOF' markers
resource "aws_iam_user_policy" "user_policy_allow_user_a_bucket_a" {
    name = "user_policy_allow_user_a_bucket_a"
    user = aws_iam_user.user_account_a.name


    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:*",
          ],
          "Resource" : [
            aws_s3_bucket.bucket_account_a.arn,
            "${aws_s3_bucket.bucket_account_a.arn}/*",
          ]
        }
      ]
    })
}
