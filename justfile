export PYTHONPATH := "."
export AWS_REGION := "eu-west-1"
export AWS_ACCOUNT_ID := "031421732210"
export ECR_SERVING_REPO_NAME := "take-home-health-innovation-labs-serving"

# Training commands
train:
    just training/train

serve:
    just serving/serve


# Lint commands
lint-check:
    just serving/lint-check
    just training/lint-check

lint-fix:
    just serving/lint-fix
    just training/lint-fix

# Test commands
test:
    just serving/test
    just training/test

# Docker commands
docker-build-all:
    just serving/docker-build
    just training/docker-build

# CI/CD commands
ci-run:
    just lint-check
    just test

# AWS/Infrastructure commands
ecr-login:
    aws ecr get-login-password --region {{AWS_REGION}} | docker login --username AWS --password-stdin {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com

ecr-push-serving:
    docker tag serving-lambda-latest {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com/{{ECR_SERVING_REPO_NAME}}:serving-lambda-latest
    docker push {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com/{{ECR_SERVING_REPO_NAME}}:serving-lambda-latest

terraform-plan:
    cd infrastructure && terraform plan

terraform-apply:
    cd infrastructure && terraform apply -auto-approve

lambda-deploy:
    aws lambda update-function-code \
        --function-name pii-redaction-api \
        --image-uri {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com/{{ECR_SERVING_REPO_NAME}}:serving-lambda-latest

lambda-build-and-deploy:
    just serving/docker-build-lambda
    just ecr-push-serving
    just lambda-deploy
