#!/bin/bash

# Save the current directory
PREV_DIR=$(pwd)

read -sp 'Enter your GitHub Token: ' GH_TOKEN

# cleanup terraform
terraform -chdir="$PREV_DIR" destroy -auto-approve -var="gh_token=$GH_TOKEN"

if [ $? -ne 0 ]; then
  echo "Error destroying resources"
  exit 1
else
    echo "Resources destroyed"
    echo "Cleanup s3 bucket"
    aws s3 rb s3://cookiecutter-lambda-backend --force
    if [ $? -ne 0 ]; then
      echo "Error deleting bucket, Please delete it manually"
      exit 1
    else
      echo "Bucket deleted"
    fi
fi
