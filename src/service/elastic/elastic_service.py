import json
import ssl
from datetime import datetime
from pathlib import Path
from typing import Mapping, Any

from elasticsearch import Elasticsearch

from oam import log_config
from oam.environment import ELASTIC_HOSTNAME, ELASTIC_PORT, ELASTIC_SCHEME, ELASTIC_USERNAME, ELASTIC_PASSWORD

logger = log_config.get_logger(__name__)


class ElasticService:
    """
    Service class for interacting with ElasticSearch.
    """
    def __init__(self):
        """
        Initialize the ElasticSearch client and create the necessary indices.
        """
        try:
            logger.info(f"Creating ElasticService instance: {ssl.OPENSSL_VERSION}")
            self.client = Elasticsearch(
                hosts=[{"host": ELASTIC_HOSTNAME,
                        "port": int(ELASTIC_PORT),
                        "scheme": ELASTIC_SCHEME}],

                http_auth=(ELASTIC_USERNAME, ELASTIC_PASSWORD),
                ssl_show_warn=False,
                verify_certs=False,
            )
            # Initialize indices
            indices_to_initialize = [f.stem for f in Path('install/elastic/mappings').glob('*.json')]
            logger.info(f"Indices to initialize: {indices_to_initialize}, "
                        f"based on the files available in 'install/elastic/mappings'")
            [self.initialize_index(index) for index in indices_to_initialize]
            logger.info(f"Elastic indices are initialized")
        except Exception as e:
            logger.error(f"Error initializing ElasticService: {e.__class__}\n{e}")
        logger.info(f"ElasticService instance is created")

    def initialize_index(self, index_name: str):
        """
        Initialize an ElasticSearch index with the correct mapping.
        """
        logger.info(f"Initializing index '{index_name}'")
        try:
            if not self.client.indices.exists(index=index_name):
                logger.info(f"Index '{index_name}' does not exist. Creating...")
                with open(f'install/elastic/{index_name}.json') as json_file:
                    logger.info(f"Loading mapping for index '{index_name} from file'")
                    mapping = json.load(json_file)
                    logger.info(f"Mapping is loaded... Creating index '{index_name}' with the loaded mapping")
                    self.client.indices.create(index=index_name, body=mapping)
                    logger.info(f"Index '{index_name}' is created.")
            else:
                logger.info(f"Index '{index_name}' already exists.")
        except Exception as e:
            logger.error(f"Error creating index '{index_name}': {e}")

    def search(self, index: str, body: Mapping[str, Any] | None):
        """
        Search for documents in the specified index.
        """
        try:
            return self.client.search(index=index.lower(), body=body)
        except Exception as e:
            logger.error(f"Error searching index '{index}': {e.__class__}\n{e}")

    def index(self, index: str, body: Mapping[str, Any] | None):
        """
        Index a document in the specified index.
        """
        try:
            return self.client.index(index=index.lower(), body=body)
        except Exception as e:
            logger.error(f"Error indexing document in index '{index}': {e.__class__}\n{e}")

    def add_to_index(self, index: str, body: Mapping[str, Any] | None, ts=None):
        """
        Add a document to the specified index.
        """
        # Generate a new timestamp for each call if ts is not provided
        if ts is None:
            ts = datetime.now().strftime("%Y%m%d%H%M%S%f")
        if body is None:
            logger.warning(f"Empty body is was provided for the document. Index {index}")
            body = {}
        if body.get("timestamp") is None:
            # If timestamp is not provided, add the current timestamp
            body["timestamp"] = datetime.now().isoformat

        try:
            return self.client.index(index=index.lower(), id=ts, body=body)
        except Exception as e:
            logger.error(f"Error adding document to index '{index}': {e.__class__}\n{e}")

    def delete(self, index: str, ts: str):
        """
        Delete a document from the specified index.
        """
        try:
            return self.client.delete(index=index.lower(), id=ts)
        except Exception as e:
            logger.error(f"Error deleting document from index '{index}': {e.__class__}\n{e}")
