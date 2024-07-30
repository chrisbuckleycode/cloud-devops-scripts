resource "aws_api_gateway_rest_api" "example" {
  body = file("${path.module}/api.json")

  name = var.rest_api_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    redeployment = sha1(aws_api_gateway_rest_api.example.body)
  }

  lifecycle {
    create_before_destroy = true
  }
}
