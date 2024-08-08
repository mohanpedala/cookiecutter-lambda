FROM --platform=linux/amd64 public.ecr.aws/lambda/python:3.9

# Install Git
RUN yum install -y git

# Copy function code
COPY package/* ${LAMBDA_TASK_ROOT}

# Ensure the script is executable
RUN chmod +x ${LAMBDA_TASK_ROOT}/cookie.py

# Install dependencies
RUN pip install -r requirements.txt

# Set the CMD to your handler
CMD [ "cookie.handler" ]
