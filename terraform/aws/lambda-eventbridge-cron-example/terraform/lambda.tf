data "archive_file" "python_lambda_package" {  
  type        = "zip"  
  source_file = "../src/lambda_function.py" 
  output_path = "lambda_function_payload.zip"
}


resource "aws_lambda_function" "lambda_function" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256

  runtime       = "python3.9"

  environment {
    variables = {
      foo = "bar"
    }
  }

  depends_on = [
    data.archive_file.python_lambda_package,
    aws_iam_role_policy_attachment.lambda_logs,
  ]


  tags = {
    Name = "Lambda Function"
  }
}


resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.self_trigger_10m.arn
}
