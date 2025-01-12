resource "aws_ecr_repository" "take_home_health_innovation_labs_serving" {
  name = "take-home-health-innovation-labs-serving"
}

resource "aws_ecr_repository" "take_home_health_innovation_labs_training" {
  name = "take-home-health-innovation-labs-training"
}

data "aws_ecr_lifecycle_policy_document" "keep_last_3" {
  rule {
    priority = 1
    description = "Keep last 3 images"
    selection {
      tag_status = "any"
      count_type = "imageCountMoreThan"
      count_number = 3
    }
    action {
      type = "expire"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "serving_policy" {
  repository = aws_ecr_repository.take_home_health_innovation_labs_serving.name
  policy     = data.aws_ecr_lifecycle_policy_document.keep_last_3.json
}

resource "aws_ecr_lifecycle_policy" "training_policy" {
  repository = aws_ecr_repository.take_home_health_innovation_labs_training.name
  policy     = data.aws_ecr_lifecycle_policy_document.keep_last_3.json
}

