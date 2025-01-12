export PYTHONPATH := "."

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
    docker build -t training-app -f training/Dockerfile .

docker-train:
    docker run training-app

docker-build-serving:
    docker build -t serving-app -f serving/Dockerfile .

docker-build-serving-lambda:
    docker build -t serving-app-lambda -f serving/Dockerfile.lambda .

docker-serve:
    docker run -p 8000:8000 serving-app

ci-run:
    just lint-check
    just test
