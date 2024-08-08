variable "region" {
  default = "us-east-1"
}

variable "lambda_function_name" {
  default = "cookiecutter-lambda"
}

variable "lambda_handler" {
  default = "cookie.lambda_cookie"
}

variable "runtime" {
  default = "python3.9"
}

variable "role_name" {
  default = "lambda-execution-role"
}

variable "gh_token" {
  type = string
}