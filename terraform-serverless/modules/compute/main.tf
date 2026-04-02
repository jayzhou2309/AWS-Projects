# API Gateway - This creates an HTTP API for your serverless app
resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "serverless-api"
  protocol_type = "HTTP"
  description   = "HTTP API for serverless Lambda function"
}

# Lambda Function - The core compute resource
resource "aws_lambda_function" "lambda_function" {
  function_name = "serverless-lambda"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = data.archive_file.lambda_zip.output_path  # Use data source for ZIP
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256  # Ensures updates trigger redeploy
}

# Data source to create ZIP from source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"  # Assumes lambda_function.py exists in this module dir
  output_path = "${path.module}/lambda_function.zip"
}

# IAM Role for Lambda - Allows Lambda service to assume this role
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"
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

# Attach AWS managed policy for basic Lambda execution (CloudWatch logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom IAM Policy for DynamoDB access
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "lambda-dynamodb-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = var.dynamodb_table_arn  # Use variable instead of module reference for flexibility
      }
    ]
  })
}

# Attach the custom policy to the role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# API Gateway Integration - Connects API Gateway to Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  integration_type = "AWS_PROXY"  # For Lambda proxy integration
  connection_type  = "INTERNET"
  integration_method = "POST"
  integration_uri  = aws_lambda_function.lambda_function.invoke_arn
}

# API Gateway Route - Defines the endpoint (e.g., GET /)
resource "aws_apigatewayv2_route" "get_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "GET /"  # Change to your desired route
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# API Gateway Deployment - Creates a deployment for the API
resource "aws_apigatewayv2_deployment" "deployment" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  description = "Deployment for serverless API"
  depends_on  = [aws_apigatewayv2_route.get_route]  # Ensure route exists
}

# API Gateway Stage - Makes the API accessible (e.g., at /prod)
resource "aws_apigatewayv2_stage" "stage" {
  api_id        = aws_apigatewayv2_api.api_gateway.id
  name          = "prod"
  deployment_id = aws_apigatewayv2_deployment.deployment.id
}

# Lambda Permission - Allows API Gateway to invoke the Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"  # Allows all routes
}

