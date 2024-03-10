from aws_cdk import (
    aws_events as events,
    aws_lambda as _lambda,
    aws_s3 as _s3,
    aws_iam as _iam,
    aws_cloudwatch as _cw,
    aws_events_targets as targets,
    App, Duration, Stack
)
import os

account=os.environ["CDK_DEFAULT_ACCOUNT"]
region=os.environ["CDK_DEFAULT_REGION"]


class LambdaCronStack(Stack):
    def __init__(self, app: App, id: str) -> None:
        super().__init__(app, id)

        # Create an S3 bucket
        bucket_name = os.environ["IMAGE_BUCKET"]
        bucket = _s3.Bucket(self, bucket_name)

        with open("lambda-handler.py", encoding="utf8") as fp:
            handler_code = fp.read()

        lambdaFn = _lambda.Function(
            self, "Singleton",
            code=_lambda.InlineCode(handler_code),
            handler="index.main",
            timeout=Duration.seconds(300),
            runtime=_lambda.Runtime.PYTHON_3_12,
        )

        # Run every day at 6PM UTC
        # See https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
        rule = events.Rule(
            self, "Rule",
            schedule=events.Schedule.cron(
                minute='*/2',
                hour='*',
                month='*',
                week_day='?'),
        )
        rule.add_target(targets.LambdaFunction(lambdaFn))

        # Grant the Lambda function read access to the S3 bucket
        bucket.grant_read(lambdaFn)

        # Grant the Lambda function write access to the S3 bucket
        bucket.grant_put(lambdaFn)

        # Grant the Lambda function permission to create CloudWatch log groups and streams
        lambdaFn.add_to_role_policy(
            _iam.PolicyStatement(
                actions=['logs:CreateLogGroup', 'logs:CreateLogStream'],
                resources=['*']
            )
        )

        # Grant the Lambda function permission to put logs events to CloudWatch
        lambdaFn.add_to_role_policy(
            _iam.PolicyStatement(
                actions=['logs:PutLogEvents'],
                # Commented out due to circular reference, temporarily allow access to all log groups
                # resources=[f'arn:aws:logs:{region}:{account}:log-group:/aws/lambda/{lambdaFn.function_name}:*']
                resources=[f'arn:aws:logs:{region}:{account}:log-group:/aws/lambda/*']
            )
        )


app = App()
LambdaCronStack(app, "LambdaCronExample")
app.synth()
