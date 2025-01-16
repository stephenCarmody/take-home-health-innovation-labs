import os

os.environ["LAMBDA_TASK_ROOT"] = "."

import pytest
from fastapi.testclient import TestClient

from serving.app import app


class FakeModel:
    def invoke(self, text: str) -> str:
        return "REDACTED"


def get_test_model():
    return FakeModel()


@pytest.fixture(autouse=True)
def mock_env():
    os.environ["LAMBDA_TASK_ROOT"] = "."
    yield
    os.environ.pop("LAMBDA_TASK_ROOT", None)


@pytest.fixture(autouse=True)
def mock_model(monkeypatch):
    fake_model = FakeModel()
    monkeypatch.setattr("serving.app.model", fake_model)

    # Mock metadata for info endpoint
    fake_metadata = {
        "model_type": "bert-base-NER",
        "run_id": "0.1.0",
        "training_time": "2024-03-19",
        "user": "test_user",
    }
    monkeypatch.setattr("serving.app.metadata", fake_metadata)
    yield


@pytest.fixture
def client():
    return TestClient(app)


def test_redact_endpoint(client):
    test_text = "Please contact John Doe at john@email.com"
    response = client.post("/redact", json={"text": test_text})

    assert response.status_code == 200
    assert response.json() == {"redacted_text": "REDACTED"}


def test_info_endpoint(client):
    response = client.get("/info")
    assert response.status_code == 200
    assert response.json() == {
        "model_name": "bert-base-NER",
        "version": "0.1.0",
        "training_date": "2024-03-19",
        "git_sha": "unknown",
        "user": "test_user",
    }
