"""
Test utilities and fixtures for the telegram-frontend-python service.

This module provides common test utilities, fixtures, and helper functions
to improve testability and reduce code duplication across test files.
"""

import pytest
import asyncio
from unittest.mock import Mock, AsyncMock, patch
from typing import Any, Dict, List, Optional
import sys
from pathlib import Path
import importlib.util

# Add src to path for imports
SRC_PATH = Path(__file__).resolve().parents[1] / 'src'
if SRC_PATH.exists():
    sys.path.insert(0, str(SRC_PATH))


def import_from_src(module_relative_path: str, module_name: str):
    """Dynamically import a module from the src directory."""

    module_path = SRC_PATH / Path(module_relative_path)
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    if spec is None or spec.loader is None:
        raise ImportError(f"Unable to load module {module_name} from {module_path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module


Kline = import_from_src('db/model/binance/kline.py', 'telegram_frontend.db.model.binance.kline').Kline
MACD = import_from_src('db/model/binance/macd.py', 'telegram_frontend.db.model.binance.macd').MACD
Order = import_from_src('db/model/binance/order.py', 'telegram_frontend.db.model.binance.order').Order
Ticker = import_from_src('db/model/binance/ticker.py', 'telegram_frontend.db.model.binance.ticker').Ticker
SignalsService = import_from_src(
    'service/crypto/signals/signals_service.py',
    'telegram_frontend.service.crypto.signals.signals_service'
).SignalsService


class TestDataFactory:
    """Factory class for creating test data objects."""
    
    @staticmethod
    def create_kline(
        symbol: str = "BTCUSDT",
        interval: str = "1m",
        open_time: int = 1620000000000,
        close_time: int = 1620000999000,
        open_price: float = 100.0,
        high_price: float = 110.0,
        low_price: float = 90.0,
        close_price: float = 105.0,
        volume: float = 1000.0,
        **kwargs
    ) -> Kline:
        """Create a test Kline object with default or custom values."""
        return Kline(
            symbol=symbol,
            interval=interval,
            open_time=open_time,
            close_time=close_time,
            open_price=open_price,
            high_price=high_price,
            low_price=low_price,
            close_price=close_price,
            volume=volume,
            **kwargs
        )
    
    @staticmethod
    def create_macd(
        symbol: str = "BTCUSDT",
        interval: str = "1m",
        timestamp: int = 1620000000000,
        macd: float = 1.5,
        signal: float = 1.2,
        histogram: float = 0.3,
        **kwargs
    ) -> MACD:
        """Create a test MACD object with default or custom values."""
        return MACD(
            symbol=symbol,
            interval=interval,
            timestamp=timestamp,
            macd=macd,
            signal=signal,
            histogram=histogram,
            **kwargs
        )
    
    @staticmethod
    def create_order(
        order_id: int = 12345,
        symbol: str = "BTCUSDT",
        side: str = "BUY",
        order_type: str = "LIMIT",
        quantity: float = 0.1,
        price: float = 100.0,
        status: str = "NEW",
        **kwargs
    ) -> Order:
        """Create a test Order object with default or custom values."""
        return Order(
            order_id=order_id,
            symbol=symbol,
            side=side,
            order_type=order_type,
            quantity=quantity,
            price=price,
            status=status,
            **kwargs
        )
    
    @staticmethod
    def create_ticker(
        symbol: str = "BTCUSDT",
        price: float = 100.0,
        volume: float = 1000.0,
        **kwargs
    ) -> Ticker:
        """Create a test Ticker object with default or custom values."""
        return Ticker(
            symbol=symbol,
            price=price,
            volume=volume,
            **kwargs
        )


class MockFactory:
    """Factory class for creating common mocks."""
    
    @staticmethod
    def create_async_repository_mock() -> Mock:
        """Create a mock repository with async methods."""
        mock_repo = Mock()
        mock_repo.save = AsyncMock()
        mock_repo.find_by_id = AsyncMock()
        mock_repo.find_all = AsyncMock()
        mock_repo.delete = AsyncMock()
        mock_repo.update = AsyncMock()
        return mock_repo
    
    @staticmethod
    def create_service_mock() -> Mock:
        """Create a mock service with common methods."""
        mock_service = Mock()
        mock_service.process = AsyncMock()
        mock_service.validate = Mock()
        mock_service.initialize = AsyncMock()
        return mock_service
    
    @staticmethod
    def create_database_mock() -> Mock:
        """Create a mock database connection."""
        mock_db = Mock()
        mock_db.connect = AsyncMock()
        mock_db.disconnect = AsyncMock()
        mock_db.execute = AsyncMock()
        mock_db.fetch = AsyncMock()
        return mock_db


@pytest.fixture
def test_data_factory():
    """Provide TestDataFactory instance."""
    return TestDataFactory()


@pytest.fixture
def mock_factory():
    """Provide MockFactory instance."""
    return MockFactory()


@pytest.fixture
def sample_kline_data():
    """Provide sample kline data for testing."""
    return [
        TestDataFactory.create_kline(close_price=100.0),
        TestDataFactory.create_kline(close_price=101.0),
        TestDataFactory.create_kline(close_price=99.0),
        TestDataFactory.create_kline(close_price=102.0),
        TestDataFactory.create_kline(close_price=98.0),
    ]


@pytest.fixture
def sample_macd_data():
    """Provide sample MACD data for testing."""
    return [
        TestDataFactory.create_macd(macd=1.0, signal=0.8, histogram=0.2),
        TestDataFactory.create_macd(macd=1.2, signal=1.0, histogram=0.2),
        TestDataFactory.create_macd(macd=1.1, signal=1.1, histogram=0.0),
        TestDataFactory.create_macd(macd=0.9, signal=1.2, histogram=-0.3),
        TestDataFactory.create_macd(macd=0.8, signal=1.0, histogram=-0.2),
    ]


@pytest.fixture
def mock_signals_service():
    """Provide a mock signals service."""
    mock_service = Mock(spec=SignalsService)
    mock_service.calculate_rsi = Mock(return_value=50.0)
    mock_service.calculate_macd = Mock(return_value=(1.0, 0.8, 0.2))
    mock_service.is_buy_signal = Mock(return_value=True)
    mock_service.is_sell_signal = Mock(return_value=False)
    return mock_service


@pytest.fixture
def event_loop():
    """Provide an event loop for async tests."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


class AsyncTestMixin:
    """Mixin class for async test utilities."""
    
    @staticmethod
    async def run_async_test(coro):
        """Run an async test coroutine."""
        return await coro
    
    @staticmethod
    def create_async_mock(*args, **kwargs):
        """Create an async mock."""
        return AsyncMock(*args, **kwargs)


class DatabaseTestMixin:
    """Mixin class for database test utilities."""
    
    @staticmethod
    def mock_database_connection():
        """Mock a database connection."""
        with patch('db.storage.get_connection') as mock_conn:
            mock_conn.return_value = MockFactory.create_database_mock()
            yield mock_conn
    
    @staticmethod
    def mock_repository(repo_class):
        """Mock a repository class."""
        with patch(repo_class) as mock_repo:
            mock_repo.return_value = MockFactory.create_async_repository_mock()
            yield mock_repo


class ServiceTestMixin:
    """Mixin class for service test utilities."""
    
    @staticmethod
    def mock_external_api(api_url: str, response_data: Dict[str, Any]):
        """Mock an external API call."""
        with patch('requests.get') as mock_get:
            mock_response = Mock()
            mock_response.json.return_value = response_data
            mock_response.status_code = 200
            mock_get.return_value = mock_response
            yield mock_get
    
    @staticmethod
    def mock_kafka_producer():
        """Mock a Kafka producer."""
        with patch('kafka.KafkaProducer') as mock_producer:
            mock_producer.return_value = Mock()
            yield mock_producer


# Test configuration constants
class TestConfig:
    """Test configuration constants."""
    
    # Database
    TEST_DATABASE_URL = "sqlite:///:memory:"
    TEST_DATABASE_NAME = "test_binance_traders"
    
    # API
    TEST_BINANCE_API_URL = "https://api.binance.com/api/v3"
    TEST_API_KEY = "test_api_key"
    TEST_SECRET_KEY = "test_secret_key"
    
    # Kafka
    TEST_KAFKA_BOOTSTRAP_SERVERS = "localhost:9092"
    TEST_KAFKA_TOPIC = "test_topic"
    
    # Redis
    TEST_REDIS_URL = "redis://localhost:6379/0"
    
    # Test data
    TEST_SYMBOL = "BTCUSDT"
    TEST_INTERVAL = "1m"
    TEST_TIMESTAMP = 1620000000000


# Utility functions
def assert_approximately_equal(actual: float, expected: float, tolerance: float = 0.001):
    """Assert that two float values are approximately equal."""
    assert abs(actual - expected) <= tolerance, f"Expected {expected}, got {actual}"


def assert_list_contains(items: List[Any], expected_item: Any):
    """Assert that a list contains a specific item."""
    assert expected_item in items, f"Expected {expected_item} to be in {items}"


def assert_dict_contains_keys(data: Dict[str, Any], expected_keys: List[str]):
    """Assert that a dictionary contains specific keys."""
    for key in expected_keys:
        assert key in data, f"Expected key '{key}' not found in {data}"


# Performance testing utilities
class PerformanceTestMixin:
    """Mixin class for performance testing utilities."""
    
    @staticmethod
    def measure_execution_time(func):
        """Decorator to measure function execution time."""
        import time
        
        def wrapper(*args, **kwargs):
            start_time = time.time()
            result = func(*args, **kwargs)
            end_time = time.time()
            execution_time = end_time - start_time
            print(f"Function {func.__name__} executed in {execution_time:.4f} seconds")
            return result
        return wrapper
    
    @staticmethod
    def assert_execution_time_under(func, max_time: float):
        """Assert that a function executes under a specified time."""
        import time
        
        start_time = time.time()
        result = func()
        end_time = time.time()
        execution_time = end_time - start_time
        
        assert execution_time <= max_time, f"Function took {execution_time:.4f}s, expected under {max_time}s"
        return result
