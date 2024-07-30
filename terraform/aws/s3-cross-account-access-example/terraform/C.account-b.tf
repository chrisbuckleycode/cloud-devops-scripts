# - Account B: User
# - Account B: Role
# - Account B: Identity policy allowing access to bucket (delegation to user) REQUIRES knowing Bucket name in A/C A.
# - Account B: Bind above policy to role
# -----------------------------------------------------------

# - Account B: User
resource "aws_iam_user" "user_account_b" {
  name = "user_account_b"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.user_account_b.arn]
    }
  }
}

resource "aws_iam_role" "role_account_b_access_bucket_a" {
  name = "role_account_b_access_bucket_a"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Action" : [
            "s3:GetObject",
            "s3:ListBucket",
          ],
          "Effect" : "Allow",
          "Resource" : [
            "arn:aws:s3:::bucket-account-a-f73gd7s6/*",
            "arn:aws:s3:::bucket-account-a-f73gd7s6"
          ]
        },
      ]
    })
  }
}
