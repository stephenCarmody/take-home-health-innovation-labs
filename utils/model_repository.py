from typing import Dict, Any, List, Tuple
from datetime import UTC, datetime
import os
import uuid
import joblib
import boto3
import json
import io

from utils.interfaces import M, T


class S3ModelRepository:
    def __init__(self, bucket_name: str):
        self.bucket_name = bucket_name
        self.s3 = boto3.client("s3")

    def persist_model(self, model: M, tokenizer: T, input_features: List[str], run_id: str) -> None:
        artifacts = _create_model_artifacts(model, tokenizer, input_features)
        buffer = io.BytesIO()
        joblib.dump(artifacts, buffer)
        self.s3.put_object(
            Bucket=self.bucket_name,
            Key=f"models/prod/{run_id}/model.joblib",
            Body=buffer.getvalue()
        )
        metadata = _create_model_metadata(run_id)
        self.s3.put_object(
            Bucket=self.bucket_name,
            Key=f"models/prod/{run_id}/metadata.json",
            Body=json.dumps(metadata),
        )
    
    def load_model(self, run_id: str) -> Tuple[M, T]:
        buffer = io.BytesIO()
        self.s3.get_object(
            Bucket=self.bucket_name,
            Key=f"models/prod/{run_id}/model.joblib",
            Body=buffer
        )
        return joblib.load(buffer)
    
    def load_metadata(self, run_id: str) -> Dict[str, str]:
        response = self.s3.get_object(
            Bucket=self.bucket_name,
            Key=f"models/prod/{run_id}/metadata.json",
        )
        return json.loads(response["Body"].read().decode("utf-8"))


class LocalModelRepository:
    def persist_model(self, model: M, tokenizer: T, input_features: List[str], run_id: str) -> None:
        artifacts = _create_model_artifacts(model, tokenizer, input_features)
        os.makedirs(f"model/{run_id}", exist_ok=True)
        joblib.dump(artifacts, f"model/{run_id}/model.joblib")

        metadata = _create_model_metadata(run_id)
        with open(f"model/{run_id}/metadata.json", "w") as f:
            json.dump(metadata, f)

    def load_model(self, run_id: str) -> Tuple[M, T]:
        artifacts = joblib.load(f"model/{run_id}/model.joblib")
        return artifacts
    
    def load_metadata(self, run_id: str) -> Dict[str, str]:
        with open(f"model/{run_id}/metadata.json", "r") as f:
            return json.load(f)


def _create_model_artifacts(
    model: M, tokenizer: T, input_features: List[str]
) -> Dict[str, Any]:
    """Creates a dictionary containing model artifacts for serialization."""
    return {
        "estimator": model,
        "tokenizer": tokenizer,
        "input_features": input_features,
    }


def _create_model_metadata(run_id: str) -> Dict[str, str]:
    """Creates metadata dictionary for model tracking and versioning."""
    return {
        "run_id": run_id,
        "training_time": datetime.now(UTC).isoformat(),
        "model_type": "fake_pii_redactor",
        "user": "stephen.m.carmody@gmail.com",
    }


def generate_run_id() -> str:
    """Generates a unique run ID using timestamp and UUID."""
    timestamp = datetime.now(UTC).strftime("%Y%m%d-%H%M%S")
    unique_id = str(uuid.uuid4())[:8]
    return f"{timestamp}-{unique_id}"
