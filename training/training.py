from typing import Any, Dict

from utils.fake_models import FakePIIModel, FakeTokenizer
from utils.model_repository import (
    LocalModelRepository,
    S3ModelRepository,
    generate_run_id,
)

from settings import settings


def tune_hyperparameters() -> Dict[str, Any]:
    """Returns best hyperparameters found during tuning."""
    print("Tuning hyperparameters... (not really)")
    return {"learning_rate": 0.001, "batch_size": 32, "epochs": 3}


def evaluate_model(model: FakePIIModel) -> Dict[str, float]:
    """Evaluates model performance and returns metrics."""
    print("Evaluating model... (not really)")
    return {"precision": 0.95, "recall": 0.98, "f1": 0.965}


def run_training(local_mode: bool = False) -> None:
    """Runs the training pipeline and saves model artifacts."""
    run_id = generate_run_id()
    input_features = ["DUMMY_INPUT_FEATURE"]

    print("Starting training pipeline...")

    params = tune_hyperparameters()
    print(f"Best parameters found: {params}")

    model = FakePIIModel()
    tokenizer = FakeTokenizer()
    model.fit("dummy input", "expected output")

    metrics = evaluate_model(model)
    print(f"Model metrics: {metrics}")
    print(model.predict("dummy input"))

    if local_mode:
        model_repository = LocalModelRepository()
    else:
        model_repository = S3ModelRepository(settings.bucket_name)

    model_repository.persist_model(model, tokenizer, input_features, run_id)
    print(
        f"\nSaved model artifacts to {'local' if local_mode else f's3://{settings.bucket_name}'}"
    )


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--local",
        action="store_true",
        help="Save model artifacts locally instead of S3",
    )
    args = parser.parse_args()
    run_training(local_mode=args.local)
