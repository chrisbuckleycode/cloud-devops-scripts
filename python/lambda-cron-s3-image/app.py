from aws_cdk import (
    aws_events as events,
    aws_lambda as _lambda,
    aws_s3 as _s3,
    aws_iam as _iam,
    aws_cloudwatch as _cw,
    aws_events_targets as targets,
    App, Duration, Stack
)
import os, subprocess # os, subprocess required for lambda layers to download dependencies

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
            layers=[self.create_dependencies_layer(self.stack_name, "lambda-handler")],
            environment=dict(BUCKET_NAME=bucket.bucket_name) # passing the upload bucket to the handler function
        )

        # Run every 2 minutes
        # See https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
        rule = events.Rule(
            self, "Rule",
            schedule=events.Schedule.cron(minute='0/2'),
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

        # Grant the Lambda function permission to put metric data
        lambdaFn.add_to_role_policy(
            _iam.PolicyStatement(
                actions=['cloudwatch:PutMetricData'],
                resources=['*']
            )
        )


    def create_dependencies_layer(self, project_name, function_name: str) -> _lambda.LayerVersion:
        requirements_file = "requirements-handler.txt" # requirements for the handler only
        output_dir = f".build/app"  # temporary directory to store the dependencies

        if not os.environ.get("SKIP_PIP"):
            # download the dependencies and store them in the output_dir
            subprocess.check_call(f"pip install -r {requirements_file} -t {output_dir}/python".split())

        layer_id = f"{project_name}-{function_name}-dependencies"  # a unique id for the layer
        layer_code = _lambda.Code.from_asset(output_dir)  # import the dependencies / code

        my_layer = _lambda.LayerVersion(
            self,
            layer_id,
            code=layer_code,
        )

        return my_layer


app = App()
LambdaCronStack(app, "LambdaCronExample")
app.synth()
