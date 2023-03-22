# S3 Cross Account Access Example

Boiler plate code example for an S3 bucket in an account "A" with IAM access to a user in the same account. Additionally, IAM has been created to allow access to a user in a different account "B".

This is a common use case in AWS and is documented here:

- [Example 2: Bucket owner granting cross-account bucket permissions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-walkthroughs-managing-access-example2.html)
- [How can I provide cross-account access to objects that are in Amazon S3 buckets?](https://repost.aws/knowledge-center/cross-account-access-s3)

For simplicity, Terraform state is local. Ensure you use a remote backend for production!

## Summary of Resources Created

### First Steps
- Account A: User
- Account A: S3 bucket
- Account A: Bucket policy denying insecure traffic
- Account A: Bind above policy to bucket
- Account A: Identity policy allow access to bucket
- Account A: Bind above policy to user

### Cross-Account Steps
- Account A: Bucket policy allowing account B to s3:ListBucket, s3:GetObject (administrators automatically inherit) REQUIRES knowing A/C B principal (user or role coming in).
- Account A: Bind above policy to bucket
- Account B: User
- Account B: Role
- Account B: Identity policy allowing access to bucket (delegation to user) REQUIRES knowing Bucket name in A/C A.
- Account B: Bind above policy to role

Note: the series of steps on account B (delegating permissions) might seem unnecessary but this is how AWS works, setting cross-account permissions in a mutual fashion i.e. on BOTH sides.
There is an alternative way to achieve the above with creating a role in account "A" that is then assumed from a role in account "B". So instead of a bucket policy in account "A" (on only one resource) you can instead define multiple permissions on multiple resources in the assumed role in account "A". For our use case above of a single bucket, this is unnecessary.

## Instructions

Make sure to authenticate to AWS e.g.

```
$ export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
$ export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
$ export AWS_DEFAULT_REGION=us-east-1
```

## Future Ideas
- Testing
