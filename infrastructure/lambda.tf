resource "aws_lambda_function" "pii_redaction" {
  function_name = "pii-redaction-api"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.take_home_health_innovation_labs_serving.repository_url}:serving-lambda-latest"
  role          = aws_iam_role.lambda_role.arn

  memory_size = 1024
  timeout     = 30
}
