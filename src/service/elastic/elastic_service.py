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

    def store_data(self, account_info, ticker, klines):
        self.index("account_info", account_info)
        self.index("ticker", ticker)
        self.index("klines", klines)
