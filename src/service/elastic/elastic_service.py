from datetime import datetime

from elasticsearch import Elasticsearch

from oam import log_config

logger = log_config.get_logger(__name__)


class ElasticService:
    def __init__(self):
        self.client = Elasticsearch(
            hosts=[{"host": "localhost", "port": 9200}],
            http_auth=("elastic", "changeme"),
        )

    def search(self, index, body):
        return self.client.search(index=index, body=body)

    def index(self, index, body):
        return self.client.index(index=index, body=body)

    def add_to_index(self, index, body, ts=datetime.now().strftime("%Y%m%d%H%M%S%f")):
        if ts:
            return self.client.index(index=index, id=ts, body=body)
        else:
            return self.client.index(index=index, body=body)

    def delete(self, index, id):
        return self.client.delete(index=index, id=id)

    def store_data(self, account_info, ticker, klines):
        self.index("account_info", account_info)
        self.index("ticker", ticker)
        self.index("klines", klines)
