data "aws_ecr_repository" "app" {
  name = "take-home-health-innovation-labs"
}

resource "aws_lambda_function" "pii_redaction" {
  function_name = "pii-redaction-api"
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.app.repository_url}:serving-lambda-latest"
  role          = aws_iam_role.lambda_role.arn

  memory_size = 1024
  timeout     = 30
}
