output "api_gateway_url" {
  description = "The invoke URL for the API Gateway stage"
  value       = aws_apigatewayv2_stage.stage.invoke_url
}