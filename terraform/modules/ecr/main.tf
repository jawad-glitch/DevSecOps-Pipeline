# modules/ecr/main.tf

# Define the container image registry repository
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "IMMUTABLE" # Enforces that tags cannot be overwritten by a malicious or accidental pipeline push

  image_scanning_configuration {
    scan_on_push = true # Triggers an automatic vulnerability scan the moment an image hits the registry
  }
}

# Attach a storage optimization policy rule to clear older images
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain only the last 10 images to actively minimize cloud storage costs"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
