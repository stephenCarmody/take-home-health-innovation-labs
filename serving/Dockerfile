FROM python:3.11-slim

RUN apt-get -y update && apt-get -y install curl

ARG poetry_version=1.8.4
ARG GIT_SHA
ENV GIT_SHA=$GIT_SHA

RUN curl -sSL https://install.python-poetry.org | python3 - --version ${poetry_version}
ENV PATH="/root/.local/bin/:$PATH"

WORKDIR /usr/src/serving

COPY serving/ ./
COPY pyproject.toml ./
COPY poetry.lock ./

RUN poetry config virtualenvs.create false && \
    poetry install --no-root --no-dev --no-interaction

EXPOSE 8000

CMD ["python", "app.py"]
