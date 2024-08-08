#!/bin/bash

# Save the current directory
PREV_DIR=$(pwd)

# Look for aws credentials
if [ -z "$AWS_PROFILE" ]; then
  echo "AWS_PROFILE is not set"
  exit 1
fi

# Set AWS_PROFILE
export AWS_PROFILE=personal

# Create a new bucket
if aws s3api head-bucket --bucket cookiecutter-lambda-backend > /dev/null 2>&1; then
    echo "Bucket already exists"
else
    aws s3api create-bucket --bucket cookiecutter-lambda-backend --region us-east-1  > /dev/null 2>&1
    echo "Bucket Created"
fi

read -sp 'Enter your GitHub Token: ' GH_TOKEN

# verify if terraform is installed
if ! [ -x "$(command -v terraform --version)" ]; then
  echo 'Error: Terraform is not installed.' >&2
  exit 1
else
  echo "Terraform is installed"
  terraform -chdir="$PREV_DIR" init
  terraform -chdir="$PREV_DIR" plan -var="gh_token=$GH_TOKEN"
  terraform -chdir="$PREV_DIR" apply -auto-approve -var="gh_token=$GH_TOKEN"
fi