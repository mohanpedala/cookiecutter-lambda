terraform {
  backend "s3" {
    bucket = "cookiecutter-lambda-backend"
    key    = "*"
    region = "us-east-1"
  }
}