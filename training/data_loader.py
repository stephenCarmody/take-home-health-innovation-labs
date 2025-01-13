import pandas as pd


def load_data():
    """Load the data from the data source"""
    data = pd.read_json("data/pii_data.json")
    return data


if __name__ == "__main__":
    load_data()
