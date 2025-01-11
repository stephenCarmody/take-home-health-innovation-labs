train:
    poetry run python training/training.py

serve:
    poetry run python serving/app.py

docker-build:
    docker build -t training-app -f training/Dockerfile .

docker-train:
    docker run training-app

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
