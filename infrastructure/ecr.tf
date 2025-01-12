resource "aws_ecr_repository" "take_home_health_innovation_labs" {
  name = "take-home-health-innovation-labs"
}

resource "aws_ecr_lifecycle_policy" "take_home_health_innovation_labs_policy" {
  repository = aws_ecr_repository.take_home_health_innovation_labs.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 3 serving images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["serving"]
          countType     = "imageCountMoreThan"
          countNumber   = 3
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 3 training images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["training"]
          countType     = "imageCountMoreThan"
          countNumber   = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

