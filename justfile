export PYTHONPATH := "."
export AWS_REGION := "eu-west-1"
export AWS_ACCOUNT_ID := "031421732210"
export ECR_SERVING_REPO_NAME := "take-home-health-innovation-labs-serving"

init:
    cd utils && poetry install
    cd serving && poetry install
    cd training && poetry install
    cd infrastructure && terraform init

# Training commands
train:
    just training/train

serve:
    cp -r training/model serving/model
    just serving/serve


# Lint commands
lint-check:
    just serving/lint-check
    just training/lint-check
    just utils/lint-check

lint-fix:
    just serving/lint-fix
    just training/lint-fix
    just utils/lint-fix

# Test commands
test:
    just serving/test
    just training/test
    just utils/test

# Docker commands
docker-build-all:
    just serving/docker-build
    just training/docker-build


# CI/CD commands
ci-run:
    just lint-check
    just test


# Infrastructure commands
tf-plan:
    cd infrastructure && terraform plan

tf-apply:
    cd infrastructure && terraform apply -auto-approve

tf-get-api-endpoint:
    cd infrastructure && terraform output -json


# Lambda & ECR commands
ecr-login:
    aws ecr get-login-password --region {{AWS_REGION}} | docker login --username AWS --password-stdin {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com

ecr-push-serving:
    docker tag serving-lambda-latest {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com/{{ECR_SERVING_REPO_NAME}}:serving-lambda-latest
    docker push {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com/{{ECR_SERVING_REPO_NAME}}:serving-lambda-latest

lambda-deploy:
    aws lambda update-function-code \
        --function-name pii-redaction-api \
        --image-uri {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com/{{ECR_SERVING_REPO_NAME}}:serving-lambda-latest

lambda-build-and-deploy:
    just serving/docker-build-lambda
    just ecr-push-serving
    just lambda-deploy


# Quick Endpoint testing
ep-info:
    curl -X GET "https://w0onfo4wd5.execute-api.eu-west-1.amazonaws.com/prod/info" | jq

ep-redact:
    curl -X POST "https://w0onfo4wd5.execute-api.eu-west-1.amazonaws.com/prod/redact" \
        -H "Content-Type: application/json" \
        -d '{"text": "Hello, my name is John Doe and my email is john.doe@example.com"}' | jq
