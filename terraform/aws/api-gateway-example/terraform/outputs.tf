output "curl_stage_invoke_url_ROOT_GET" {
  description = "API Gateway Stage Invoke URL"
  value       = "curl ${aws_api_gateway_stage.example.invoke_url}"
}

output "curl_stage_invoke_url_pets_GET" {
  description = "API Gateway Stage Invoke URL - /pets GET"
  value       = "curl ${aws_api_gateway_stage.example.invoke_url}/pets/"
}

locals {
  curl_post = templatefile("curl_post.txt", { invoke_url = aws_api_gateway_stage.example.invoke_url })
}

output "curl_stage_invoke_url_pets_POST_example" {
  description = "API Gateway Stage Invoke URL - /pets POST example"
  value       = "${local.curl_post}"
}
