
import numpy as np
import joblib
from pathlib import Path

class MLModel:
    def __init__(self, estimator, tokenizer, input_features):
        self._estimator = estimator
        self._tokenizer = tokenizer
        self._input_features = input_features

    @property
    def estimator(self):
        return self._estimator

    @property
    def tokenizer(self):
        return self._tokenizer

    @property
    def input_features(self):
        return self._input_features

    def prediction_postprocess(self, text: str) -> str:
        """
        Replace any tokens marked as a Named Entity with the entity name
        """
        return text

    def invoke(self, text: str) -> str:
        """
        Predict which tokens are named entities
        """
        return self.prediction_postprocess(self._predict(text))
    
    def _predict(self, text: str) -> str:
        """
        Predict which tokens are named entities
        """
        return self.estimator.predict(text)

    def load(cls, path: Path) -> "MLModel":
        """
        Load a model from a path
        """
        with open(path, "rb") as file:
            model_artifacts = joblib.load(file)
        return MLModel(**model_artifacts)

    def save(self, path: Path):
        """
        Save a model as artifacts
        """
        artifacts = {
            "estimator": self.estimator,
            "tokenizer": self.tokenizer,
            "input_features": self.input_features
        }
        joblib.dump(artifacts, path)
