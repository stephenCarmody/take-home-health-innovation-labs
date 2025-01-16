from typing import Any, List, Protocol, TypeVar, Tuple, Dict

class ModelProtocol(Protocol):
    def fit(self, X: Any, y: Any) -> None: ...
    def predict(self, X: Any) -> Any: ...


class TokenizerProtocol(Protocol):
    def tokenize(self, text: str) -> List[str]: ...


class ModelRepositoryProtocol(Protocol):
    def persist_model(self, model: ModelProtocol, tokenizer: TokenizerProtocol, input_features: List[str], run_id: str, bucket_name: str) -> None: ...
    def load_model(self, run_id: str, bucket_name: str) -> Tuple[ModelProtocol, TokenizerProtocol]: ...
    def load_metadata(self, run_id: str, bucket_name: str) -> Dict[str, str]: ...


# Create type vars from protocols
M = TypeVar('M', bound=ModelProtocol)
T = TypeVar('T', bound=TokenizerProtocol)
