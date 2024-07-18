import ssl
from _ssl import PROTO_TLSv1_3
from datetime import datetime
from typing import Mapping, Any

from elasticsearch import Elasticsearch

from oam import log_config
from oam.environment import ELASTIC_HOSTNAME, ELASTIC_PORT, ELASTIC_SCHEME
from ssl import create_default_context, PROTOCOL_TLS, TLSVersion

logger = log_config.get_logger(__name__)


class ElasticService:
    def __init__(self):
        logger.info(f"Creating ElasticService instance: {ssl.OPENSSL_VERSION}")
        self.client = Elasticsearch(
            hosts=[{"host": ELASTIC_HOSTNAME,
                    "port": int(ELASTIC_PORT),
                    "scheme": ELASTIC_SCHEME}],

            http_auth=("elastic", "changeme"),
            ssl_show_warn=False,

            verify_certs=False,
        )
        # Initialize indices
        self.initialize_index("btcu")

    def initialize_index(self, index_name: str):
        """
        Initialize an ElasticSearch index with the correct mapping.
        """
        logger.info(f"Initializing index '{index_name}'")
        try:
            if not self.client.indices.exists(index=index_name):
                mapping = \
                    {"mappings": {
                        "properties": {
                            "timestamp": {
                                "type": "date"
                            },
                            "ticker": {
                                "properties": {
                                    "symbol": {
                                        "type": "keyword"
                                    },
                                    "priceChange": {
                                        "type": "double"
                                    },
                                    "priceChangePercent": {
                                        "type": "double"
                                    },
                                    "weightedAvgPrice": {
                                        "type": "double"
                                    },
                                    "prevClosePrice": {
                                        "type": "double"
                                    },
                                    "lastPrice": {
                                        "type": "double"
                                    },
                                    "lastQty": {
                                        "type": "double"
                                    },
                                    "bidPrice": {
                                        "type": "double"
                                    },
                                    "bidQty": {
                                        "type": "double"
                                    },
                                    "askPrice": {
                                        "type": "double"
                                    },
                                    "askQty": {
                                        "type": "double"
                                    },
                                    "openPrice": {
                                        "type": "double"
                                    },
                                    "highPrice": {
                                        "type": "double"
                                    },
                                    "lowPrice": {
                                        "type": "double"
                                    },
                                    "volume": {
                                        "type": "double"
                                    },
                                    "quoteVolume": {
                                        "type": "double"
                                    },
                                    "openTime": {
                                        "type": "date"
                                    },
                                    "closeTime": {
                                        "type": "date"
                                    },
                                    "firstId": {
                                        "type": "long"
                                    },
                                    "lastId": {
                                        "type": "long"
                                    },
                                    "count": {
                                        "type": "integer"
                                    }
                                }
                            }
                        }
                    }, }
                self.client.indices.create(index=index_name, body=mapping)
                logger.info(f"Created index '{index_name}' with correct mapping.")
            else:
                logger.info(f"Index '{index_name}' already exists.")
        except Exception as e:
            logger.error(f"Error creating index '{index_name}': {e}")

    def search(self, index: str, body: Mapping[str, Any] | None):
        return self.client.search(index=index.lower(), body=body)

    def index(self, index: str, body: Mapping[str, Any] | None):
        return self.client.index(index=index.lower(), body=body)

    def add_to_index(self, index: str, body: Mapping[str, Any] | None, ts=datetime.now().strftime("%Y%m%d%H%M%S%f")):
        if ts:
            return self.client.index(index=index.lower(), id=ts, body=body)
        else:
            return self.client.index(index=index.lower(), body=body)

    def delete(self, index: str, ts: str):
        return self.client.delete(index=index.lower(), id=ts)
