resource "aws_lambda_function" "pii_redaction" {
  function_name = "pii-redaction-api"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.take_home_health_innovation_labs_serving.repository_url}:serving-lambda-latest"
  role          = aws_iam_role.lambda_role.arn
  architectures = ["arm64"]

  memory_size = 1024
  timeout     = 30

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      LOG_LEVEL = "DEBUG"
    }
  }
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "pii-redaction-api-gateway"
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.lambda_api.name}"
  retention_in_days = 7
}

resource "aws_apigatewayv2_stage" "lambda_api" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  name   = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip            = "$context.identity.sourceIp"
      requestTime   = "$context.requestTime"
      httpMethod    = "$context.httpMethod"
      routeKey      = "$context.routeKey"
      status        = "$context.status"
      protocol      = "$context.protocol"
      responseLength = "$context.responseLength"
      errorMessage  = "$context.error.message"
    })
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.lambda_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.pii_redaction.invoke_arn
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "redact" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "POST /redact"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "info" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "GET /info"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pii_redaction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

output "api_endpoint" {
  value = "${aws_apigatewayv2_api.lambda_api.api_endpoint}"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.pii_redaction.function_name}"
  retention_in_days = 30
}