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

    def delete(self, index, id):
        return self.client.delete(index=index, id=id)

    def store_data(self, account_info, ticker, klines):
        self.index("account_info", account_info)
        self.index("ticker", ticker)
        self.index("klines", klines)
