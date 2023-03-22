resource "aws_cloudwatch_event_rule" "self_trigger_10m" {
  name                = "self_trigger_10m"
  description         = "Self trigger on automated schedule, every 10 minutes"
  schedule_expression = "rate(10 minutes)"
}


resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.self_trigger_10m.id
  arn       = aws_lambda_function.lambda_function.arn
}
