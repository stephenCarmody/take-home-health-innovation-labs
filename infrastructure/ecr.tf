resource "aws_ecr_repository" "take_home_health_innovation_labs" {
  name = "take-home-health-innovation-labs"
}

resource "aws_ecr_lifecycle_policy" "take_home_health_innovation_labs_policy" {
  repository = aws_ecr_repository.take_home_health_innovation_labs.name

    policy = jsonencode({
      rules = [{
        rulePriority = 1
        description  = "Keep last 3 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 3
        }
      action = {
        type = "expire"
      }
    }]
  })
}

