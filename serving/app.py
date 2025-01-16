import logging
import os

from fastapi import FastAPI
from mangum import Mangum
from pydantic import BaseModel

from serving.settings import settings
from utils.model_repository import LocalModelRepository
from utils.model_wrapper import MLModel

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

GIT_SHA = os.getenv("GIT_SHA", "unknown")


artifacts = LocalModelRepository().load_model(settings.model_id)
model = MLModel(**artifacts)
metadata = LocalModelRepository().load_metadata(settings.model_id)

app = FastAPI(title="PII Redaction API", root_path="/prod")


class RedactRequest(BaseModel):
    text: str


class RedactResponse(BaseModel):
    redacted_text: str


class ModelInfo(BaseModel):
    model_name: str
    version: str
    training_date: str
    git_sha: str
    user: str


@app.post("/redact", response_model=RedactResponse)
async def redact_text(request: RedactRequest) -> RedactResponse:
    response = model.invoke(request.text)
    return RedactResponse(redacted_text=response)


@app.get("/info", response_model=ModelInfo)
async def get_model_info() -> ModelInfo:
    return ModelInfo(
        model_name=metadata["model_type"],
        version=metadata["run_id"],
        training_date=metadata["training_time"],
        git_sha=GIT_SHA,
        user=metadata["user"],
    )


handler = Mangum(app, api_gateway_base_path="/prod")

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
