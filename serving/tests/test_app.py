from fastapi.testclient import TestClient

from serving.app import app

client = TestClient(app)


def test_redact_endpoint():
    response = client.post("/redact", json={"text": "Hello World"})
    assert response.status_code == 200
    assert response.json() == {"redacted_text": "pong"}


def test_info_endpoint():
    response = client.get("/info")
    assert response.status_code == 200
    assert response.json() == {
        "model_name": "bert-base-NER",
        "version": "0.1.0",
        "training_date": "2024-03-19",
        "git_sha": "unknown",
    }
