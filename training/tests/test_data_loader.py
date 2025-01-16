from unittest.mock import patch

import pandas as pd
import pytest

from training.data_loader import load_data


@pytest.fixture
def mock_json_data():
    return [
        {"text": "Hello World", "redacted_text": "[GREETING] World"},
        {"text": "My name is John", "redacted_text": "My name is [NAME]"},
    ]


@pytest.fixture
def expected_df(mock_json_data):
    return pd.DataFrame(mock_json_data)


def test_load_data(mock_json_data, expected_df):
    with patch("pandas.read_json") as mock_read_json:
        # Given
        mock_read_json.return_value = pd.DataFrame(mock_json_data)

        # When
        result = load_data()

        # Then
        mock_read_json.assert_called_once_with("data/pii_data.json")

        assert isinstance(result, pd.DataFrame)
        pd.testing.assert_frame_equal(result, expected_df)
