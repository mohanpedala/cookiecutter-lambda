from cookiecutter.main import cookiecutter
import requests
import os
import shutil
import json
import subprocess

# Function to run shell commands
def run_command(command, cwd=None):
    result = subprocess.run(command, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        raise Exception(f"Command '{' '.join(command)}' returned non-zero exit status {result.returncode}: {result.stderr}")
    return result.stdout

def handler(event, context):

    # Get GH token from Env
    github_token = os.environ['GH_TOKEN']
    
    print(f"GitHub Token: {github_token}")
    print(f"Event: {event}")

    headers = {
        'Accept': 'application/vnd.github.mercy-preview+json',
        'Authorization': f'token {github_token}'
    }

    # Repo details
    template_repo_url = event['template_repo_url']
    new_repo_name = event['new_repo_name']
    org_name = event['new_repo_owner']

    tmp_dir = "/tmp"
    if not os.path.exists(tmp_dir):
        os.makedirs(tmp_dir)

    # Temp dir to store the generated cookiecutter project
    # Set HOME environment variable to /tmp
    os.environ['HOME'] = tmp_dir

    try:

        if requests.get(f"https://api.github.com/repos/{org_name}/{new_repo_name}", headers=headers).status_code == 200:
            # do nothing
            print(f"Repository {new_repo_name} already exists!")
        else:
            # Create a new repo for the org in GitHub
            new_repo_response = requests.post(
                f"https://api.github.com/user/repos",
                headers=headers,
                json={"name": new_repo_name, "private": True}
            )
            print(f"New Repo Response: {new_repo_response.text}")
            new_repo_response.raise_for_status()

        new_repo_url = f"https://github.com/{org_name}/{new_repo_name}"
        print(f"New Repo URL: {new_repo_url}")

        # Extra context for cookiecutter
        extra_context = {
            "repo_name": new_repo_name,
            "artifact_id": new_repo_name,
            "group_id": new_repo_name,
            "version": "1.0.1-SNAPSHOT",
            "package_name": "com.mohan.com",
            "repo_url": new_repo_url
        }

        print(f"Extra Context: {extra_context}")

        # Add token to repository URL
        template_repo_url = template_repo_url.replace("https://", f"https://{github_token}@")
        print(f"Modified Template Repo URL: {template_repo_url}")
        print(f"os.getcwd(): {os.getcwd()}")
        print(f"os.listdir(): {os.listdir()}")
        print(f"os.listdir(/tmp): {os.listdir('/tmp')}")
        try:
            cookiecutter(
                template_repo_url,
                no_input=True,
                config_file="config.yaml",
                extra_context=extra_context,
                output_dir=tmp_dir,
                overwrite_if_exists=True
            )

            print(f"After cookiecutter os.listdir(): {os.listdir()}")
            print(f"After cookiecutter os.listdir(/tmp): {os.listdir('/tmp')}")

        except Exception as e:
            print(f"Failed to generate cookiecutter project: {e}")
            raise

        print(f"Cookiecutter project generated successfully!")

        # Change to the project directory
        project_dir = os.path.join(tmp_dir, new_repo_name)
        print(f"Project Directory: {project_dir}")

        git_remote_url = f"https://{github_token}@github.com/{org_name}/{new_repo_name}.git"

        # Set Global Git Config
        run_command(["git", "config", "--global", "user.email", "sample@test.com"])
        run_command(["git", "config", "--global", "user.name", "sample"])
                        
        # Initialize git and push the project to GitHub
        run_command(["git", "init"], cwd=project_dir)
        existing_remotes = run_command(["git", "remote"], cwd=project_dir).splitlines()
        if "origin" in existing_remotes:
            run_command(["git", "remote", "remove", "origin"], cwd=project_dir)
        run_command(["git", "remote", "add", "origin", git_remote_url], cwd=project_dir)
        run_command(["git", "branch", "-M", "main"], cwd=project_dir)
        run_command(["git", "add", "."], cwd=project_dir)
        run_command(["git", "commit", "-m", "Initial commit"], cwd=project_dir)
        run_command(["git", "push", "-u", "origin", "main"], cwd=project_dir)

    except requests.exceptions.RequestException as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Failed to create repository: {e}')
        }
    except subprocess.CalledProcessError as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Failed to push changes: {e}')
        }
    except Exception as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Unexpected error: {e}')
        }
    # finally:
    #     # Cleanup the temp directory
    #     shutil.rmtree(tmp_dir, ignore_errors=True)

    return {
        'statusCode': 201,
        'body': json.dumps(f'Repository {new_repo_name} created successfully!')
    }
