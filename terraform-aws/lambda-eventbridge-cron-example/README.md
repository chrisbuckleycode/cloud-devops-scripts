Boiler plate code example for executing a Lambda cron job.

Note: EventBridge was formerly called CloudWatch Events. To be more accurate, CloudWatch Events and EventBridge are the same underlying service and API, but EventBridge provides more features. Changes you make in either CloudWatch or EventBridge will appear in each console.

For simplicity, Terraform state is local. Ensure you use a remote backend for production!

Make sure to authenticate to AWS e.g.

```
$ export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
$ export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
$ export AWS_DEFAULT_REGION=us-east-1
```

More examples here: [Lambda code examples for the AWS SDK for Python](https://github.com/awsdocs/aws-doc-sdk-examples/tree/main/python/example_code/lambda)