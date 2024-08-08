output "lambda_function_arn" {
  value = aws_lambda_function.cookiecutter_lambda.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.create_lambda_repo.repository_url
}