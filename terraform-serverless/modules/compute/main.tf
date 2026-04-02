# API Gateway
resource "aws_apigatewayv2_api" "api_gateway" {
  name = "api_gateway"
  protocol_type = "HTTP"
}

# Lambda Function
resource "aws_lambda_function" "lambda_function" {
  function_name = "lambda_function"
  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"
  role = aws_iam_role.lambda_role.arn
  filename = "lambda_function.zip"
}

#IAM Role for Lambda permissions to DynamoDB put,get,delete items
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}