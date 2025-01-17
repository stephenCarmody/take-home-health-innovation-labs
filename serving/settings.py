import os
from functools import lru_cache

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings.

    Uses Pydantic BaseSettings to load configuration from environment variables.
    """

    # AWS Settings
    bucket_name: str = "pii-redaction-model-artifacts"
    model_s3_prefix: str = "models/prod/"

    # Model
    model_id: str = os.getenv("MODEL_ID", "20250117-121915-eeba0222")

    # Paths
    local_model_dir: str = "model"


settings = Settings()
