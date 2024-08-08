resource "aws_ecr_repository" "create_lambda_repo" {
  name                 = "cookiecutter-lambda-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "create_lambda_repo_lifecycle_policy" {
  repository = aws_ecr_repository.create_lambda_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 2 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "null_resource" "docker_build_and_push" {
  depends_on = [aws_ecr_repository.create_lambda_repo]
  provisioner "local-exec" {
    command = <<EOT
      # Authenticate Docker to ECR
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.create_lambda_repo.repository_url}

      # Build the Docker image
      docker build -t cookie-cutter-lambda . --platform=linux/amd64

      # Tag the Docker image
      docker tag cookie-cutter-lambda:latest ${aws_ecr_repository.create_lambda_repo.repository_url}:latest

      # Push the Docker image
      docker push ${aws_ecr_repository.create_lambda_repo.repository_url}:latest
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}