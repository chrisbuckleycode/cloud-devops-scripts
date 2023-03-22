# - Account A: Bucket policy allowing account B to s3:ListBucket, s3:GetObject (administrators automatically inherit) REQUIRES knowing A/C B principal (user or role coming in).
# - Account A: Bind above policy to bucket
# -----------------------------------------------------------

# Note: even though the policy is a bucket policy, we use the Terraform resource aws_iam_policy_document
# which is fine, so long as a principal is present
# Another way to attach a policy, using a separate "data" resource
data "aws_iam_policy_document" "bucket_policy_allow_from_account_b" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["776945069435"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.bucket_account_a.arn,
      "${aws_s3_bucket.bucket_account_a.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "bind_bucket_a_account_b" {
  bucket = aws_s3_bucket.bucket_account_a.id
  policy = data.aws_iam_policy_document.bucket_policy_allow_from_account_b.json
}
