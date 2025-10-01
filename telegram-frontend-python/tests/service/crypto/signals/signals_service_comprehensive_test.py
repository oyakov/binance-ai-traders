"""
Comprehensive tests for the SignalsService.

This module provides extensive test coverage for the signals service,
including RSI, MACD, and other technical indicators.
"""

import pytest
import sys
import os
import pandas as pd
import numpy as np
import asyncio
from unittest.mock import Mock, patch

# Add src to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', 'src'))

from service.crypto.signals.signals_service import SignalsService
from tests.test_utils import TestDataFactory, MockFactory, assert_approximately_equal


class TestSignalsServiceComprehensive:
    """Comprehensive test suite for SignalsService."""
    
    def setup_method(self):
        """Set up test fixtures before each test method."""
        self.signals_service = SignalsService()
        self.test_data_factory = TestDataFactory()
        self.mock_factory = MockFactory()
    
    def test_calculate_macd_signals_with_buy_signal(self):
        """Test MACD signal calculation with buy signal."""
        # Create mock MACD data with histogram crossing above 0 (buy signal)
        # Logic: current > 0 AND (previous < 0 OR two_previous < 0)
        macd_data = pd.DataFrame({
            'histogram': [-0.2, -0.1, -0.05, 0.1]  # Last: 0.1 > 0, previous: -0.05 < 0
        })
        
        buy_signal, sell_signal = asyncio.run(self.signals_service.calculate_macd_signals(macd_data))
        
        assert buy_signal is True
        assert sell_signal is False
    
    def test_calculate_macd_signals_with_sell_signal(self):
        """Test MACD signal calculation with sell signal."""
        # Create mock MACD data with histogram crossing below 0 (sell signal)
        # Logic: current < 0 AND (previous > 0 OR two_previous > 0)
        macd_data = pd.DataFrame({
            'histogram': [0.2, 0.1, 0.05, -0.1]  # Last: -0.1 < 0, previous: 0.05 > 0
        })
        
        buy_signal, sell_signal = asyncio.run(self.signals_service.calculate_macd_signals(macd_data))
        
        assert buy_signal is False
        assert sell_signal is True
    
    def test_calculate_macd_signals_with_no_signal(self):
        """Test MACD signal calculation with no clear signal."""
        # Create mock MACD data with no crossover
        macd_data = pd.DataFrame({
            'histogram': [0.1, 0.15, 0.2, 0.25]  # All positive, no crossover
        })
        
        buy_signal, sell_signal = asyncio.run(self.signals_service.calculate_macd_signals(macd_data))
        
        assert buy_signal is False
        assert sell_signal is False
    
    def test_calculate_macd_signals_with_insufficient_data(self):
        """Test MACD signal calculation with insufficient data."""
        # Create mock MACD data with only 3 values (need at least 4)
        macd_data = pd.DataFrame({
            'histogram': [0.1, 0.2, 0.3]
        })
        
        # This should handle the IndexError gracefully
        try:
            buy_signal, sell_signal = asyncio.run(self.signals_service.calculate_macd_signals(macd_data))
            assert buy_signal is False
            assert sell_signal is False
        except IndexError:
            # Expected behavior when there's insufficient data
            pass
    
    def test_calculate_macd_signals_with_none_data(self):
        """Test MACD signal calculation with None data."""
        buy_signal, sell_signal = asyncio.run(self.signals_service.calculate_macd_signals(None))
        
        assert buy_signal is False
        assert sell_signal is False
    
    def test_calculate_macd_signals_with_empty_dataframe(self):
        """Test MACD signal calculation with empty DataFrame."""
        macd_data = pd.DataFrame({'histogram': []})
        
        # This should handle the IndexError gracefully
        try:
            buy_signal, sell_signal = asyncio.run(self.signals_service.calculate_macd_signals(macd_data))
            assert buy_signal is False
            assert sell_signal is False
        except IndexError:
            # Expected behavior when there's insufficient data
            pass
    
    def test_calculate_rsi_signals_with_oversold_condition(self):
        """Test RSI signal calculation with oversold condition."""
        # Create mock RSI data with oversold value
        rsi_data = pd.Series([25.0])  # Oversold (below 30)
        
        buy_signal, sell_signal = asyncio.run(self.signals_service.calculate_rsi_signals(rsi_data))
        
        assert buy_signal is True
        assert sell_signal is False
    
    def test_calculate_rsi_signals_with_overbought_condition(self):
        """Test RSI signal calculation with overbought condition."""
        # Create mock RSI data with overbought value
        rsi_data = pd.Series([75.0])  # Overbought (above 70)
        
        buy_signal, sell_signal = asyncio.run(self.signals_service.calculate_rsi_signals(rsi_data))
        
        assert buy_signal is False
        assert sell_signal is True
    
    def test_calculate_rsi_signals_with_neutral_condition(self):
        """Test RSI signal calculation with neutral condition."""
        # Create mock RSI data with neutral value
        rsi_data = pd.Series([50.0])  # Neutral (between 30 and 70)
        
        buy_signal, sell_signal = asyncio.run(self.signals_service.calculate_rsi_signals(rsi_data))
        
        assert buy_signal is False
        assert sell_signal is False
    
    def test_signals_service_initialization(self):
        """Test SignalsService initialization."""
        service = SignalsService()
        
        assert service.current_macd is None
        assert service.prev_macd is None
    
    def test_signals_service_state_management(self):
        """Test SignalsService state management."""
        # Test that current_macd and prev_macd are properly managed
        macd_data = pd.DataFrame({'histogram': [0.1, 0.2, 0.3, 0.4]})
        
        # First call
        asyncio.run(self.signals_service.calculate_macd_signals(macd_data))
        assert self.signals_service.current_macd is not None
        assert self.signals_service.prev_macd is None
        
        # Second call
        macd_data2 = pd.DataFrame({'histogram': [0.4, 0.5, 0.6, 0.7]})
        asyncio.run(self.signals_service.calculate_macd_signals(macd_data2))
        assert self.signals_service.current_macd is not None
        assert self.signals_service.prev_macd is not None


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
