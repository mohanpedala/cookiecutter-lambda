resource "aws_lambda_function" "cookiecutter_lambda" {
  depends_on    = [null_resource.docker_build_and_push]
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_execution_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.create_lambda_repo.repository_url}:latest"
  timeout       = "60"
  environment {
    variables = {
      # set token from system environment variable
      GH_TOKEN = var.gh_token
    }
  }
}
