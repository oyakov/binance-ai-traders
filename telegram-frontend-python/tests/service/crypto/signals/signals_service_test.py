import unittest
from unittest.async_case import IsolatedAsyncioTestCase

from pandas import Series

import sys
from pathlib import Path

# Ensure the src directory is available on the import path when tests are executed
SRC_PATH = Path(__file__).resolve().parents[4] / 'src'
if SRC_PATH.exists():
    sys.path.insert(0, str(SRC_PATH))

from tests.test_utils import SignalsService


class MyTestCase(IsolatedAsyncioTestCase):

    def setUp(self):
        print("\nRunning setUp method...")
        self.signals_service = SignalsService()

    async def test_verifyThatRsiBuySignalCalculated(self):
        rsi = Series(data=[29])
        buy, sell = await self.signals_service.calculate_rsi_signals(rsi)
        print(buy, sell)
        self.assertEqual(buy, True)
        self.assertEqual(sell, False)

    async def test_verifyThatRsiSellSignalCalculated(self):
        rsi = Series(data=[71])
        buy, sell = await self.signals_service.calculate_rsi_signals(rsi)
        print(buy, sell)
        self.assertEqual(buy, False)
        self.assertEqual(sell, True)


if __name__ == '__main__':
    unittest.main()
