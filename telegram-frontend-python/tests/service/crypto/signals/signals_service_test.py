import unittest
from unittest.async_case import IsolatedAsyncioTestCase

from pandas import Series, DataFrame

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'src'))

from service.crypto.signals.signals_service import SignalsService


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
