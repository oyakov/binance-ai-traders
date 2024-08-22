import pandas as pd

from oam import log_config

logger = log_config.get_logger(__name__)

class FilesystemService:
    def __init__(self):
        logger.info("Filesystem service initialized")

    def read_file(self, file_path: str) -> str:
        with open(file_path, 'r') as file:
            return file.read()

    def write_file(self, file_path: str, content: str):
        with open(file_path, 'w') as file:
            file.write(content)
        logger.info(f"File is written to {file_path}")

    def write_series_to_csv(self, series, file_path: str):
        series.to_csv(file_path)
        logger.info(f"Series is written to {file_path}")

    def read_csv_to_series(self, file_path: str):
        return pd.read_csv(file_path, index_col=0)

    def write_dataframe_to_csv(self, df, file_path: str):
        df.to_csv('data/' + file_path)
        logger.info(f"DataFrame is written to {file_path}")

    def read_csv_to_dataframe(self, file_path: str):
        return pd.read_csv(file_path, index_col=0)

    def write_dataframe_to_excel(self, df, file_path: str):
        df.to_excel(file_path)
        logger.info(f"DataFrame is written to {file_path}")

    def read_excel_to_dataframe(self, file_path: str):
        return pd.read_excel(file_path, index_col=0)

    def clean_directory(self, directory_path: str):
        import os
        for file in os.listdir(directory_path):
            os.remove(os.path.join(directory_path, file))
        logger.info(f"Directory {directory_path} is cleaned")

    def list_files(self, directory_path: str):
        import os
        return os.listdir(directory_path)