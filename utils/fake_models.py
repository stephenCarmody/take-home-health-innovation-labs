import numpy as np
from sklearn.dummy import DummyClassifier
from utils.interfaces import ModelProtocol, TokenizerProtocol


class FakePIIModel(ModelProtocol):
    """A dummy estimator that always predicts redaction"""
    def __init__(self):
        self.model = DummyClassifier(strategy='constant', constant=1)
        
    def fit(self, X, y):
        """Train the model"""
        self.model.fit(np.array([[1]]), np.array([1]))
        return self

    def predict(self, text: str) -> str:
        """Always returns redacted text"""
        return "[REDACTED] " + text + " [REDACTED]"
    

class FakeTokenizer(TokenizerProtocol):
    def tokenize(self, text: str) -> str:
        return text
