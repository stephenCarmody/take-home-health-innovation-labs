from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    bucket_name: str = "pii-redaction-model-artifacts"


settings = Settings()
