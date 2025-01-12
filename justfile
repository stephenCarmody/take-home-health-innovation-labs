export PYTHONPATH := "."
export AWS_REGION := "eu-west-1"
export AWS_ACCOUNT_ID := "031421732210"
export ECR_REPO_NAME := "take-home-health-innovation-labs"

train:
    poetry run python training/training.py

serve:
    poetry run python serving/app.py

lint-check:
    poetry run isort --check-only --diff serving/ training/
    poetry run black --check --diff serving/ training/

lint-fix:
    poetry run isort serving/ training/
    poetry run black serving/ training/

test:
    poetry run pytest serving/tests/ training/tests/ -v

test-serving:
    poetry run pytest serving/tests/ -v

test-training:
    poetry run pytest training/tests/ -v

docker-build-training:
    docker build -t training:$(git rev-parse --short HEAD) -t training:latest -f training/Dockerfile .

docker-train:
    docker run training:latest

docker-build-serving:
    docker build -t serving:$(git rev-parse --short HEAD) -t serving:latest -f serving/Dockerfile .

docker-build-serving-lambda:
    docker build -t serving-lambda:$(git rev-parse --short HEAD) -t serving-lambda:latest -f serving/Dockerfile.lambda .

docker-serve:
    docker run -p 8000:8000 serving:latest

ci-run:
    just lint-check
    just test


ecr-login:
    aws ecr get-login-password --region {{AWS_REGION}} | docker login --username AWS --password-stdin {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com

ecr-push-serving:
    docker tag serving:latest {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com/{{ECR_REPO_NAME}}:serving
    docker push {{AWS_ACCOUNT_ID}}.dkr.ecr.{{AWS_REGION}}.amazonaws.com/{{ECR_REPO_NAME}}:serving
