# Run CookieCutter Inside Lambda to Create a Project

This project uses an AWS Lambda function named `cookiecutter-lambda` to automate the process of cloning a GitHub template repository using Cookiecutter, creating a new GitHub repository, and pushing the generated project to the new repository.

## Features

- Clone a GitHub template repository using Cookiecutter.
- Create a new private repository in a specified GitHub organization.
- Customize the generated project using extra context values.
- Push the generated project to the new GitHub repository.

## Pre-req
* aws-cli
* docker
* terraform
* make

## Setup

## Configure AWS Environment
1. Create AWS Config Files
   ```
   [profile testenv]
   aws_access_key_id=******
   aws_secret_access_key=******
   region = us-east-1
   output = json
   ```
2. Create [Github Token}(https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

3. Bootstrap project
   - Run `make create`
   - Enter `GH_TOKEN` created in step2 when prompted
4. Cleanup Project
   - Run `make cleanup`
   - Enter `GH_TOKEN` created in step2 when prompted

## Notes:
### IAM Role Permissions

Ensure the Lambda execution role has the following permissions:
- `logs:CreateLogGroup`
- `logs:CreateLogStream`
- `logs:PutLogEvents`
- `s3:GetObject`
- `lambda:UpdateFunctionConfiguration`

### Configuring Cookiecutter

The Lambda function uses Cookiecutter to generate a project based on a template repository. Here’s how to configure and use it:

1. **Set Cookiecutter Path to `/tmp`**:
   Cookiecutter generates files in the `/tmp` directory, which is the only writable directory in AWS Lambda. Set `cookiecutters_dir` config to `/tmp`

2. **Cookiecutter Config File (`config.yaml`)**:
   Include a `config.yaml` file with any default values you want to override. The file should be located in the directory where Cookiecutter is executed.
   ```yaml
   cookiecutters_dir: "/tmp"
   replay_dir: "/tmp"
   ```
   This file allows you to set default values for fields that Cookiecutter prompts you for, reducing the amount of manual input required.

### Configuring Git

To ensure Git operations work correctly in the Lambda environment:

1. **Set Git Config Path to `/tmp`**:
   This part is handled in the python code.

   **Explanation**:
   Since the Lambda environment is stateless and `/tmp` is the only writable directory, set the global Git config to store settings in `/tmp`:
   ```bash
   git config --global --file /tmp/.gitconfig user.email "sample@test.com"
   git config --global --file /tmp/.gitconfig user.name "sample"
   ```
   These commands are executed by the Lambda function to configure Git before initializing and pushing the repository.

## Usage

1. **Invoke the Lambda Function**:
   Send a payload to the Lambda function with the required parameters:
   - `template_repo_url`: URL of the GitHub template repository.
   - `new_repo_name`: Name of the new repository to be created.
   - `new_repo_owner`: GitHub organization or user where the new repository will be created.

   **Example Payload**:
   ```json
   {
     "template_repo_url": "https://github.com/example/template-repo",
     "new_repo_name": "new-project",
     "new_repo_owner": "your-organization"
   }
   ```

2. **Lambda Execution**:
   The Lambda function will:
   - Clone the template repository using Cookiecutter.
   - Apply any specified extra context values.
   - Create a new private repository under the specified organization or user.
   - Push the generated project to the new repository.

3. **Handling Errors**:
   The function includes error handling for common issues such as repository creation failures or Git push errors. Ensure the provided GitHub token has sufficient permissions to create repositories and push changes.
