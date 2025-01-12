from fastapi import FastAPI
from mangum import Mangum
from pydantic import BaseModel
import os

app = FastAPI(title="PII Redaction API")

GIT_SHA = os.getenv("GIT_SHA", "unknown")


class RedactRequest(BaseModel):
    text: str


class RedactResponse(BaseModel):
    redacted_text: str


class ModelInfo(BaseModel):
    model_name: str
    version: str
    training_date: str
    git_sha: str


@app.post("/redact", response_model=RedactResponse)
async def redact_text(request: RedactRequest) -> RedactResponse:
    return RedactResponse(redacted_text="pong")


@app.get("/info", response_model=ModelInfo)
async def get_model_info() -> ModelInfo:
    return ModelInfo(
        model_name="bert-base-NER",
        version="0.1.0",
        training_date="2024-03-19",
        git_sha=GIT_SHA,
    )


handler = Mangum(app)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
