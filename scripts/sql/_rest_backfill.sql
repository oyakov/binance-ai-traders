INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759319999999, to_timestamp(1759276800000/1000), 113875.93, 116789, 113500, 116789, 16.11028,
  1759276800000, 1759319999999, to_timestamp(1759319999999/1000),
  1877065.3504542, 873, 2.91938, 340299.1849558, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759363199999, to_timestamp(1759320000000/1000), 116788.99, 200000, 30000, 118560.62, 207.23867,
  1759320000000, 1759363199999, to_timestamp(1759363199999/1000),
  24304268.4280061, 20115, 84.16153, 9875709.9964351, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759406399999, to_timestamp(1759363200000/1000), 118560.61, 119431.19, 45000, 118765.72, 144.85827,
  1759363200000, 1759406399999, to_timestamp(1759406399999/1000),
  17185299.6062466, 18298, 60.33499, 7160631.8443473, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759449599999, to_timestamp(1759406400000/1000), 118765.73, 121026.9, 118521.22, 120528.51, 197.85041,
  1759406400000, 1759449599999, to_timestamp(1759449599999/1000),
  23719823.5859875, 22652, 76.22758, 9139495.1743305, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759492799999, to_timestamp(1759449600000/1000), 120528.51, 120834.14, 119249.99, 120334.5, 118.55985,
  1759449600000, 1759492799999, to_timestamp(1759492799999/1000),
  14234356.3688227, 12382, 49.73131, 5970863.4100126, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759535999999, to_timestamp(1759492800000/1000), 120334.5, 200000, 119919, 122225.43, 189.5631,
  1759492800000, 1759535999999, to_timestamp(1759535999999/1000),
  23114068.3844998, 49205, 82.84783, 10111210.4958341, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759579199999, to_timestamp(1759536000000/1000), 122225.44, 122800, 120365.17, 121973.26, 95.33524,
  1759536000000, 1759579199999, to_timestamp(1759579199999/1000),
  11651915.5519013, 42955, 40.48411, 4947194.7110765, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759622399999, to_timestamp(1759579200000/1000), 121973.26, 122566.93, 25000, 122379.98, 166.48122,
  1759579200000, 1759622399999, to_timestamp(1759622399999/1000),
  20232508.1142105, 68882, 73.72449, 8970991.4826547, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759665599999, to_timestamp(1759622400000/1000), 122379.99, 130884.2, 121704.15, 123464.64, 104.53365,
  1759622400000, 1759665599999, to_timestamp(1759665599999/1000),
  12950938.5192068, 67535, 44.28048, 5488139.0236446, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759708799999, to_timestamp(1759665600000/1000), 123464.64, 124234.1, 30000, 123469.07, 153.05554,
  1759665600000, 1759708799999, to_timestamp(1759708799999/1000),
  18792875.6152702, 54821, 66.90325, 8228510.9328496, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759751999999, to_timestamp(1759708800000/1000), 123469.07, 124495.7, 94900, 124221.95, 134.6782,
  1759708800000, 1759751999999, to_timestamp(1759751999999/1000),
  16656759.2544316, 71982, 61.82001, 7650312.5546487, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759795199999, to_timestamp(1759752000000/1000), 124221.95, 126606.11, 123781.98, 124715.56, 154.98146,
  1759752000000, 1759795199999, to_timestamp(1759795199999/1000),
  19388655.2572581, 69962, 74.09255, 9268675.0432635, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759838399999, to_timestamp(1759795200000/1000), 124715.55, 126523.61, 123318.08, 124446.08, 159.4212,
  1759795200000, 1759838399999, to_timestamp(1759838399999/1000),
  19812982.0773596, 34442, 70.3202, 8740370.5150167, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759881599999, to_timestamp(1759838400000/1000), 124453.38, 126523.61, 94900, 121339.36, 294.11949,
  1759838400000, 1759881599999, to_timestamp(1759881599999/1000),
  36015440.0219227, 32851, 139.68027, 17110413.5000119, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759924799999, to_timestamp(1759881600000/1000), 121332.96, 127263.15, 121068.96, 122887.91, 237.56958,
  1759881600000, 1759924799999, to_timestamp(1759924799999/1000),
  28995048.0234892, 17764, 112.10288, 13684331.4967075, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1759967999999, to_timestamp(1759924800000/1000), 122884.14, 127655.53, 121168.59, 123306, 424.08999,
  1759924800000, 1759967999999, to_timestamp(1759967999999/1000),
  52268335.5893685, 23952, 202.22395, 24929536.157221, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1760011199999, to_timestamp(1759968000000/1000), 123306, 127738.76, 120902.8, 122737.57, 493.75519,
  1759968000000, 1760011199999, to_timestamp(1760011199999/1000),
  60292619.3771064, 23797, 240.1604, 29326922.617779, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1760054399999, to_timestamp(1760011200000/1000), 122737.56, 130889.49, 49946, 121662.4, 583.99214,
  1760011200000, 1760054399999, to_timestamp(1760054399999/1000),
  70824998.3186108, 35874, 280.23078, 34044362.34945, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1760097599999, to_timestamp(1760054400000/1000), 121689.07, 121964.48, 120203.25, 121568.26, 309.06172,
  1760054400000, 1760097599999, to_timestamp(1760097599999/1000),
  37533965.4663121, 18068, 155.37369, 18869713.255622, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1760140799999, to_timestamp(1760097600000/1000), 121568.25, 132000, 24352, 112788.82, 584.70298,
  1760097600000, 1760140799999, to_timestamp(1760140799999/1000),
  68222287.8398496, 48386, 305.32332, 35849933.8438594, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1760183999999, to_timestamp(1760140800000/1000), 112785.78, 114866, 98000.2, 112277.82, 373.85907,
  1760140800000, 1760183999999, to_timestamp(1760183999999/1000),
  41839422.330457, 31826, 177.20871, 19832315.4588389, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1760227199999, to_timestamp(1760184000000/1000), 112280.01, 113958.33, 30000, 110644.39, 320.46344,
  1760184000000, 1760227199999, to_timestamp(1760227199999/1000),
  35705695.711308, 23391, 162.90225, 18153617.9935309, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1760270399999, to_timestamp(1760227200000/1000), 110644.4, 113958.33, 50000, 111848.36, 509.03872,
  1760227200000, 1760270399999, to_timestamp(1760270399999/1000),
  56524020.082618, 30425, 253.45322, 28138844.6510198, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '12h', 1760313599999, to_timestamp(1760270400000/1000), 111848.36, 200000, 30000, 114347.73, 1014.50544,
  1760270400000, 1760313599999, to_timestamp(1760313599999/1000),
  115280950.308879, 34302, 492.44705, 55984546.4950512, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1759363199999, to_timestamp(1759276800000/1000), 113875.93, 200000, 30000, 118560.62, 223.34895,
  1759276800000, 1759363199999, to_timestamp(1759363199999/1000),
  26181333.7784603, 20988, 87.08091, 10216009.1813909, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1759449599999, to_timestamp(1759363200000/1000), 118560.61, 121026.9, 45000, 120528.51, 342.70868,
  1759363200000, 1759449599999, to_timestamp(1759449599999/1000),
  40905123.1922341, 40950, 136.56257, 16300127.0186778, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1759535999999, to_timestamp(1759449600000/1000), 120528.51, 200000, 119249.99, 122225.43, 308.12295,
  1759449600000, 1759535999999, to_timestamp(1759535999999/1000),
  37348424.7533225, 61587, 132.57914, 16082073.9058467, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1759622399999, to_timestamp(1759536000000/1000), 122225.44, 122800, 25000, 122379.98, 261.81646,
  1759536000000, 1759622399999, to_timestamp(1759622399999/1000),
  31884423.6661118, 111837, 114.2086, 13918186.1937312, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1759708799999, to_timestamp(1759622400000/1000), 122379.99, 130884.2, 30000, 123469.07, 257.58919,
  1759622400000, 1759708799999, to_timestamp(1759708799999/1000),
  31743814.134477, 122356, 111.18373, 13716649.9564942, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1759795199999, to_timestamp(1759708800000/1000), 123469.07, 126606.11, 94900, 124715.56, 289.65966,
  1759708800000, 1759795199999, to_timestamp(1759795199999/1000),
  36045414.5116897, 141944, 135.91256, 16918987.5979122, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1759881599999, to_timestamp(1759795200000/1000), 124715.55, 126523.61, 94900, 121339.36, 453.54069,
  1759795200000, 1759881599999, to_timestamp(1759881599999/1000),
  55828422.0992823, 67293, 210.00047, 25850784.0150286, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1759967999999, to_timestamp(1759881600000/1000), 121332.96, 127655.53, 121068.96, 123306, 661.65957,
  1759881600000, 1759967999999, to_timestamp(1759967999999/1000),
  81263383.6128577, 41716, 314.32683, 38613867.6539285, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1760054399999, to_timestamp(1759968000000/1000), 123306, 130889.49, 49946, 121662.4, 1077.74733,
  1759968000000, 1760054399999, to_timestamp(1760054399999/1000),
  131117617.695717, 59671, 520.39118, 63371284.967229, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1760140799999, to_timestamp(1760054400000/1000), 121689.07, 132000, 24352, 112788.82, 893.7647,
  1760054400000, 1760140799999, to_timestamp(1760140799999/1000),
  105756253.306162, 66454, 460.69701, 54719647.0994814, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1760227199999, to_timestamp(1760140800000/1000), 112785.78, 114866, 30000, 110644.39, 694.32251,
  1760140800000, 1760227199999, to_timestamp(1760227199999/1000),
  77545118.041765, 55217, 340.11096, 37985933.4523698, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1d', 1760313599999, to_timestamp(1760227200000/1000), 110644.4, 200000, 30000, 114347.73, 1523.54416,
  1760227200000, 1760313599999, to_timestamp(1760313599999/1000),
  171804970.391497, 64727, 745.90027, 84123391.146071, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '3d', 1759535999999, to_timestamp(1759276800000/1000), 113875.93, 200000, 30000, 122225.43, 874.18058,
  1759276800000, 1759535999999, to_timestamp(1759535999999/1000),
  104434881.724017, 123525, 356.22262, 42598210.1059154, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '3d', 1759795199999, to_timestamp(1759536000000/1000), 122225.44, 130884.2, 25000, 124715.56, 809.06531,
  1759536000000, 1759795199999, to_timestamp(1759795199999/1000),
  99673652.3122785, 376137, 361.30489, 44553823.7481376, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '3d', 1760054399999, to_timestamp(1759795200000/1000), 124715.55, 130889.49, 49946, 121662.4, 2192.94759,
  1759795200000, 1760054399999, to_timestamp(1760054399999/1000),
  268209423.407857, 168680, 1044.71848, 127835936.636186, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '3d', 1760313599999, to_timestamp(1760054400000/1000), 121689.07, 200000, 24352, 114347.73, 3111.63137,
  1760054400000, 1760313599999, to_timestamp(1760313599999/1000),
  355106341.739424, 186398, 1546.70824, 176828971.697922, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1w', 1759708799999, to_timestamp(1759104000000/1000), 113875.93, 200000, 25000, 123469.07, 1393.58623,
  1759104000000, 1759708799999, to_timestamp(1759708799999/1000),
  168063119.524606, 357718, 581.61495, 70233046.2561408, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BTCUSDT', '1w', 1760313599999, to_timestamp(1759708800000/1000), 123469.07, 200000, 24352, 114347.73, 5594.23862,
  1759708800000, 1760313599999, to_timestamp(1760313599999/1000),
  659361179.658971, 497022, 2727.33928, 321583895.93202, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759319999999, to_timestamp(1759276800000/1000), 4298.59, 4398.59, 4288.59, 4297.98, 25.6503,
  1759276800000, 1759319999999, to_timestamp(1759319999999/1000),
  110228.379195, 245, 17.3528, 74559.182177, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759363199999, to_timestamp(1759320000000/1000), 4299.51, 5595.17, 3528.66, 4345.37, 557.7929,
  1759320000000, 1759363199999, to_timestamp(1759363199999/1000),
  2406815.272992, 4113, 264.7699, 1142993.204666, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759406399999, to_timestamp(1759363200000/1000), 4344.73, 4810.6, 4322.03, 4381.6, 884.1889,
  1759363200000, 1759406399999, to_timestamp(1759406399999/1000),
  3874883.806569, 5267, 466.0477, 2042532.91034, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759449599999, to_timestamp(1759406400000/1000), 4378.93, 4891.64, 3880.81, 4484.22, 1232.4796,
  1759406400000, 1759449599999, to_timestamp(1759449599999/1000),
  5461318.407106, 5843, 469.5846, 2077969.960323, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759492799999, to_timestamp(1759449600000/1000), 4483.39, 4598.36, 4428.48, 4478.56, 621.1389,
  1759449600000, 1759492799999, to_timestamp(1759492799999/1000),
  2788515.660899, 3253, 301.3578, 1353299.799137, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759535999999, to_timestamp(1759492800000/1000), 4478, 6268.73, 1640.64, 4511.13, 962.6938,
  1759492800000, 1759535999999, to_timestamp(1759535999999/1000),
  4329814.672858, 5477, 370.8537, 1675351.350218, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759579199999, to_timestamp(1759536000000/1000), 4512.48, 4981.63, 4464.23, 4484.17, 442.445,
  1759536000000, 1759579199999, to_timestamp(1759579199999/1000),
  1989276.379455, 3129, 234.7603, 1055532.757971, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759622399999, to_timestamp(1759579200000/1000), 4483.84, 10000, 2000, 4487.46, 715.4834,
  1759579200000, 1759622399999, to_timestamp(1759622399999/1000),
  3205344.193186, 11118, 390.2697, 1753127.224363, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759665599999, to_timestamp(1759622400000/1000), 4487.16, 6706.38, 4363.36, 4551.15, 1104.9312,
  1759622400000, 1759665599999, to_timestamp(1759665599999/1000),
  5030132.815169, 15911, 563.4696, 2564356.941784, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759708799999, to_timestamp(1759665600000/1000), 4551.14, 5035.16, 1500, 4514.32, 1153.1937,
  1759665600000, 1759708799999, to_timestamp(1759708799999/1000),
  5215315.561815, 12393, 592.0237, 2677327.708195, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759751999999, to_timestamp(1759708800000/1000), 4514.32, 5035.16, 4479.87, 4571.94, 867.2392,
  1759708800000, 1759751999999, to_timestamp(1759751999999/1000),
  3943142.100923, 21630, 388.6164, 1767859.979042, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759795199999, to_timestamp(1759752000000/1000), 4571.94, 6996.93, 2400, 4686.07, 1891.9447,
  1759752000000, 1759795199999, to_timestamp(1759795199999/1000),
  8822211.225271, 9071, 917.3894, 4293045.786482, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759838399999, to_timestamp(1759795200000/1000), 4685.43, 6149.62, 2390, 4708.81, 1092.6291,
  1759795200000, 1759838399999, to_timestamp(1759838399999/1000),
  5103351.652374, 7497, 541.9194, 2541630.615756, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759881599999, to_timestamp(1759838400000/1000), 4708.82, 5476.2, 1500, 4448.27, 2010.2538,
  1759838400000, 1759881599999, to_timestamp(1759881599999/1000),
  9145608.016331, 26258, 959.5671, 4367480.217716, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759924799999, to_timestamp(1759881600000/1000), 4447.71, 7542.93, 3297.32, 4487.29, 1882.9289,
  1759881600000, 1759924799999, to_timestamp(1759924799999/1000),
  8411150.76391, 19062, 952.498, 4256810.8452, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1759967999999, to_timestamp(1759924800000/1000), 4487.79, 7542.93, 4021.71, 4525.2, 1525.7635,
  1759924800000, 1759967999999, to_timestamp(1759967999999/1000),
  6866850.588227, 20018, 775.0684, 3490476.877034, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1760011199999, to_timestamp(1759968000000/1000), 4525.73, 4541.72, 4192, 4373.44, 2338.7977,
  1759968000000, 1760011199999, to_timestamp(1760011199999/1000),
  10324143.319994, 22851, 1265.4583, 5585655.983232, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1760054399999, to_timestamp(1760011200000/1000), 4373.45, 5312.47, 1955.2, 4366.7, 2622.6384,
  1760011200000, 1760054399999, to_timestamp(1760054399999/1000),
  11357438.072026, 19416, 1309.1997, 5683168.412338, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1760097599999, to_timestamp(1760054400000/1000), 4368.09, 5903.84, 3990.88, 4344.31, 866.0534,
  1760054400000, 1760097599999, to_timestamp(1760097599999/1000),
  3768518.747035, 5789, 475.6633, 2071383.731217, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1760140799999, to_timestamp(1760097600000/1000), 4343.63, 6342.88, 1000, 3832.2, 3129.3547,
  1760097600000, 1760140799999, to_timestamp(1760140799999/1000),
  12686361.025908, 24472, 1485.6699, 6092545.443066, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1760183999999, to_timestamp(1760140800000/1000), 3828.69, 4900, 3352, 3839.93, 2982.6048,
  1760140800000, 1760183999999, to_timestamp(1760183999999/1000),
  11366684.148322, 22951, 1909.8615, 7287243.104781, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1760227199999, to_timestamp(1760184000000/1000), 3840, 4172.67, 1000, 3745.91, 4431.9587,
  1760184000000, 1760227199999, to_timestamp(1760227199999/1000),
  16783658.108341, 35207, 2151.9404, 8154629.244162, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1760270399999, to_timestamp(1760227200000/1000), 3746.14, 4172.67, 3639.23, 3820.36, 3380.6254,
  1760227200000, 1760270399999, to_timestamp(1760270399999/1000),
  12801808.503488, 25821, 1873.0392, 7091603.92341, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '12h', 1760313599999, to_timestamp(1760270400000/1000), 3820.36, 4962.67, 2211.95, 4089.3, 2553.04,
  1760270400000, 1760313599999, to_timestamp(1760313599999/1000),
  10317382.410958, 24936, 1311.7209, 5292816.189872, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1759363199999, to_timestamp(1759276800000/1000), 4298.59, 5595.17, 3528.66, 4345.37, 583.4432,
  1759276800000, 1759363199999, to_timestamp(1759363199999/1000),
  2517043.652187, 4358, 282.1227, 1217552.386843, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1759449599999, to_timestamp(1759363200000/1000), 4344.73, 4891.64, 3880.81, 4484.22, 2116.6685,
  1759363200000, 1759449599999, to_timestamp(1759449599999/1000),
  9336202.213675, 11110, 935.6323, 4120502.870663, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1759535999999, to_timestamp(1759449600000/1000), 4483.39, 6268.73, 1640.64, 4511.13, 1583.8327,
  1759449600000, 1759535999999, to_timestamp(1759535999999/1000),
  7118330.333757, 8730, 672.2115, 3028651.149355, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1759622399999, to_timestamp(1759536000000/1000), 4512.48, 10000, 2000, 4487.46, 1157.9284,
  1759536000000, 1759622399999, to_timestamp(1759622399999/1000),
  5194620.572641, 14247, 625.03, 2808659.982334, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1759708799999, to_timestamp(1759622400000/1000), 4487.16, 6706.38, 1500, 4514.32, 2258.1249,
  1759622400000, 1759708799999, to_timestamp(1759708799999/1000),
  10245448.376984, 28304, 1155.4933, 5241684.649979, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1759795199999, to_timestamp(1759708800000/1000), 4514.32, 6996.93, 2400, 4686.07, 2759.1839,
  1759708800000, 1759795199999, to_timestamp(1759795199999/1000),
  12765353.326194, 30701, 1306.0058, 6060905.765524, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1759881599999, to_timestamp(1759795200000/1000), 4685.43, 6149.62, 1500, 4448.27, 3102.8829,
  1759795200000, 1759881599999, to_timestamp(1759881599999/1000),
  14248959.668705, 33755, 1501.4865, 6909110.833472, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1759967999999, to_timestamp(1759881600000/1000), 4447.71, 7542.93, 3297.32, 4525.2, 3408.6924,
  1759881600000, 1759967999999, to_timestamp(1759967999999/1000),
  15278001.352137, 39080, 1727.5664, 7747287.722234, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1760054399999, to_timestamp(1759968000000/1000), 4525.73, 5312.47, 1955.2, 4366.7, 4961.4361,
  1759968000000, 1760054399999, to_timestamp(1760054399999/1000),
  21681581.39202, 42267, 2574.658, 11268824.39557, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1760140799999, to_timestamp(1760054400000/1000), 4368.09, 6342.88, 1000, 3832.2, 3995.4081,
  1760054400000, 1760140799999, to_timestamp(1760140799999/1000),
  16454879.772943, 30261, 1961.3332, 8163929.174283, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1760227199999, to_timestamp(1760140800000/1000), 3828.69, 4900, 1000, 3745.91, 7414.5635,
  1760140800000, 1760227199999, to_timestamp(1760227199999/1000),
  28150342.256663, 58158, 4061.8019, 15441872.348943, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1d', 1760313599999, to_timestamp(1760227200000/1000), 3746.14, 4962.67, 2211.95, 4089.3, 5933.6654,
  1760227200000, 1760313599999, to_timestamp(1760313599999/1000),
  23119190.914446, 50757, 3184.7601, 12384420.113282, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '3d', 1759535999999, to_timestamp(1759276800000/1000), 4298.59, 6268.73, 1640.64, 4511.13, 4283.9444,
  1759276800000, 1759535999999, to_timestamp(1759535999999/1000),
  18971576.199619, 24198, 1889.9665, 8366706.406861, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '3d', 1759795199999, to_timestamp(1759536000000/1000), 4512.48, 10000, 1500, 4686.07, 6175.2372,
  1759536000000, 1759795199999, to_timestamp(1759795199999/1000),
  28205422.275819, 73252, 3086.5291, 14111250.397837, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '3d', 1760054399999, to_timestamp(1759795200000/1000), 4685.43, 7542.93, 1500, 4366.7, 11473.0114,
  1759795200000, 1760054399999, to_timestamp(1760054399999/1000),
  51208542.412862, 115102, 5803.7109, 25925222.951276, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '3d', 1760313599999, to_timestamp(1760054400000/1000), 4368.09, 6342.88, 1000, 4089.3, 17343.637,
  1760054400000, 1760313599999, to_timestamp(1760313599999/1000),
  67724412.944052, 139176, 9207.8952, 35990221.636508, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1w', 1759708799999, to_timestamp(1759104000000/1000), 4298.59, 10000, 1500, 4514.32, 7699.9977,
  1759104000000, 1759708799999, to_timestamp(1759708799999/1000),
  34411645.149244, 66749, 3670.4898, 16417051.039174, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ETHUSDT', '1w', 1760313599999, to_timestamp(1759708800000/1000), 4514.32, 7542.93, 1000, 4089.3, 31575.8323,
  1759708800000, 1760313599999, to_timestamp(1760313599999/1000),
  131698308.683108, 284979, 16317.6119, 67976350.353308, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759319999999, to_timestamp(1759276800000/1000), 1028.66, 1029.81, 1022.12, 1024.37, 31.069,
  1759276800000, 1759319999999, to_timestamp(1759319999999/1000),
  31887.61989, 30, 26.941, 27661.31764, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759363199999, to_timestamp(1759320000000/1000), 1023.55, 1028.48, 1017.46, 1025.98, 441.082,
  1759320000000, 1759363199999, to_timestamp(1759363199999/1000),
  450791.60594, 1064, 275.707, 281891.45037, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759406399999, to_timestamp(1759363200000/1000), 1027.68, 1289.56, 1000.32, 1047.82, 678.465,
  1759363200000, 1759406399999, to_timestamp(1759406399999/1000),
  702709.01331, 1972, 392.362, 406441.88975, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759449599999, to_timestamp(1759406400000/1000), 1047.82, 1098.43, 1043.02, 1090.14, 597.781,
  1759406400000, 1759449599999, to_timestamp(1759449599999/1000),
  635485.9999, 1414, 241.991, 258724.48675, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759492799999, to_timestamp(1759449600000/1000), 1091.75, 1199.87, 928.53, 1105.86, 695.184,
  1759449600000, 1759492799999, to_timestamp(1759492799999/1000),
  760217.45256, 2512, 429.499, 469165.31615, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759535999999, to_timestamp(1759492800000/1000), 1107.94, 1507.5, 919.68, 1189.57, 857.064,
  1759492800000, 1759535999999, to_timestamp(1759535999999/1000),
  996362.67199, 3127, 403.004, 468394.47709, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759579199999, to_timestamp(1759536000000/1000), 1187, 1192.84, 700, 1151.75, 1081.653,
  1759536000000, 1759579199999, to_timestamp(1759579199999/1000),
  1258670.12215, 3158, 557.022, 648411.71339, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759622399999, to_timestamp(1759579200000/1000), 1151.82, 1192.84, 995.4, 1150.58, 1169.844,
  1759579200000, 1759622399999, to_timestamp(1759622399999/1000),
  1344349.9146, 1164, 633.645, 728872.38406, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759665599999, to_timestamp(1759622400000/1000), 1150.14, 1517.41, 951.18, 1167.58, 587.906,
  1759622400000, 1759665599999, to_timestamp(1759665599999/1000),
  688745.05339, 2097, 343.764, 404580.01447, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759708799999, to_timestamp(1759665600000/1000), 1167.53, 1552.72, 919.68, 1166.67, 708.676,
  1759665600000, 1759708799999, to_timestamp(1759708799999/1000),
  827756.02461, 4761, 368.753, 433367.07467, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759751999999, to_timestamp(1759708800000/1000), 1166.86, 1586.39, 500, 1222.7, 907.443,
  1759708800000, 1759751999999, to_timestamp(1759751999999/1000),
  1083398.50303, 3763, 573.438, 686130.52318, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759795199999, to_timestamp(1759752000000/1000), 1222.71, 1599.12, 1182.24, 1223.72, 941.656,
  1759752000000, 1759795199999, to_timestamp(1759795199999/1000),
  1155777.37392, 4729, 541.609, 666260.41602, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759838399999, to_timestamp(1759795200000/1000), 1223.47, 1637.76, 919.68, 1313.31, 1249.009,
  1759795200000, 1759838399999, to_timestamp(1759838399999/1000),
  1556456.02046, 4854, 566.075, 705812.04655, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759881599999, to_timestamp(1759838400000/1000), 1312.64, 1375.08, 750, 1304.64, 884.85,
  1759838400000, 1759881599999, to_timestamp(1759881599999/1000),
  1149191.32704, 5243, 442.068, 574976.99126, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759924799999, to_timestamp(1759881600000/1000), 1304.43, 1333.49, 1134.34, 1313.53, 583.579,
  1759881600000, 1759924799999, to_timestamp(1759924799999/1000),
  761553.39076, 2270, 294.919, 384842.44265, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1759967999999, to_timestamp(1759924800000/1000), 1314.77, 1324.5, 1163.74, 1307.4, 814.563,
  1759924800000, 1759967999999, to_timestamp(1759967999999/1000),
  1066316.80355, 1824, 434.406, 568347.00984, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1760011199999, to_timestamp(1759968000000/1000), 1307.74, 1324.5, 1256.83, 1281.71, 713.992,
  1759968000000, 1760011199999, to_timestamp(1760011199999/1000),
  921265.86975, 1545, 353.729, 455918.0164, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1760054399999, to_timestamp(1760011200000/1000), 1279.74, 1686.89, 1000, 1255.33, 876.297,
  1760011200000, 1760054399999, to_timestamp(1760054399999/1000),
  1104395.04807, 1215, 410.491, 518143.67266, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1760097599999, to_timestamp(1760054400000/1000), 1255.62, 1559.14, 1116.63, 1270.87, 1339.097,
  1760054400000, 1760097599999, to_timestamp(1760097599999/1000),
  1689131.28323, 1839, 712.149, 897842.08213, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1760140799999, to_timestamp(1760097600000/1000), 1270.4, 1579.72, 868.82, 1101.13, 3977.791,
  1760097600000, 1760140799999, to_timestamp(1760140799999/1000),
  4681062.38082, 7366, 1781.991, 2131452.26786, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1760183999999, to_timestamp(1760140800000/1000), 1102.03, 1440.51, 919.68, 1129.96, 2035.908,
  1760140800000, 1760183999999, to_timestamp(1760183999999/1000),
  2286485.78912, 2885, 1158.786, 1303683.4348, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1760227199999, to_timestamp(1760184000000/1000), 1128.83, 1454.68, 300, 1135.79, 4218.02,
  1760184000000, 1760227199999, to_timestamp(1760227199999/1000),
  4833704.86891, 6349, 2256.847, 2586561.94332, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1760270399999, to_timestamp(1760227200000/1000), 1135.07, 1534.51, 700, 1230.11, 7475.053,
  1760227200000, 1760270399999, to_timestamp(1760270399999/1000),
  8670202.76749, 9436, 3333.367, 3856301.9332, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '12h', 1760313599999, to_timestamp(1760270400000/1000), 1230.11, 1634.17, 919.68, 1287.45, 2004.25,
  1760270400000, 1760313599999, to_timestamp(1760313599999/1000),
  2535854.89361, 3227, 970.366, 1227383.15227, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1759363199999, to_timestamp(1759276800000/1000), 1028.66, 1029.81, 1017.46, 1025.98, 472.151,
  1759276800000, 1759363199999, to_timestamp(1759363199999/1000),
  482679.22583, 1094, 302.648, 309552.76801, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1759449599999, to_timestamp(1759363200000/1000), 1027.68, 1289.56, 1000.32, 1090.14, 1276.246,
  1759363200000, 1759449599999, to_timestamp(1759449599999/1000),
  1338195.01321, 3386, 634.353, 665166.3765, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1759535999999, to_timestamp(1759449600000/1000), 1091.75, 1507.5, 919.68, 1189.57, 1552.248,
  1759449600000, 1759535999999, to_timestamp(1759535999999/1000),
  1756580.12455, 5639, 832.503, 937559.79324, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1759622399999, to_timestamp(1759536000000/1000), 1187, 1192.84, 700, 1150.58, 2251.497,
  1759536000000, 1759622399999, to_timestamp(1759622399999/1000),
  2603020.03675, 4322, 1190.667, 1377284.09745, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1759708799999, to_timestamp(1759622400000/1000), 1150.14, 1552.72, 919.68, 1166.67, 1296.582,
  1759622400000, 1759708799999, to_timestamp(1759708799999/1000),
  1516501.078, 6858, 712.517, 837947.08914, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1759795199999, to_timestamp(1759708800000/1000), 1166.86, 1599.12, 500, 1223.72, 1849.099,
  1759708800000, 1759795199999, to_timestamp(1759795199999/1000),
  2239175.87695, 8492, 1115.047, 1352390.9392, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1759881599999, to_timestamp(1759795200000/1000), 1223.47, 1637.76, 750, 1304.64, 2133.859,
  1759795200000, 1759881599999, to_timestamp(1759881599999/1000),
  2705647.3475, 10097, 1008.143, 1280789.03781, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1759967999999, to_timestamp(1759881600000/1000), 1304.43, 1333.49, 1134.34, 1307.4, 1398.142,
  1759881600000, 1759967999999, to_timestamp(1759967999999/1000),
  1827870.19431, 4094, 729.325, 953189.45249, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1760054399999, to_timestamp(1759968000000/1000), 1307.74, 1686.89, 1000, 1255.33, 1590.289,
  1759968000000, 1760054399999, to_timestamp(1760054399999/1000),
  2025660.91782, 2760, 764.22, 974061.68906, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1760140799999, to_timestamp(1760054400000/1000), 1255.62, 1579.72, 868.82, 1101.13, 5316.888,
  1760054400000, 1760140799999, to_timestamp(1760140799999/1000),
  6370193.66405, 9205, 2494.14, 3029294.34999, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1760227199999, to_timestamp(1760140800000/1000), 1102.03, 1454.68, 300, 1135.79, 6253.928,
  1760140800000, 1760227199999, to_timestamp(1760227199999/1000),
  7120190.65803, 9234, 3415.633, 3890245.37812, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1d', 1760313599999, to_timestamp(1760227200000/1000), 1135.07, 1634.17, 700, 1287.45, 9479.303,
  1760227200000, 1760313599999, to_timestamp(1760313599999/1000),
  11206057.6611, 12663, 4303.733, 5083685.08547, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '3d', 1759535999999, to_timestamp(1759276800000/1000), 1028.66, 1507.5, 919.68, 1189.57, 3300.645,
  1759276800000, 1759535999999, to_timestamp(1759535999999/1000),
  3577454.36359, 10119, 1769.504, 1912278.93775, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '3d', 1759795199999, to_timestamp(1759536000000/1000), 1187, 1599.12, 500, 1223.72, 5397.178,
  1759536000000, 1759795199999, to_timestamp(1759795199999/1000),
  6358696.9917, 19672, 3018.231, 3567622.12579, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '3d', 1760054399999, to_timestamp(1759795200000/1000), 1223.47, 1686.89, 750, 1255.33, 5122.29,
  1759795200000, 1760054399999, to_timestamp(1760054399999/1000),
  6559178.45963, 16951, 2501.688, 3208040.17936, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '3d', 1760313599999, to_timestamp(1760054400000/1000), 1255.62, 1634.17, 300, 1287.45, 21050.119,
  1760054400000, 1760313599999, to_timestamp(1760313599999/1000),
  24696441.98318, 31102, 10213.506, 12003224.81358, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1w', 1759708799999, to_timestamp(1759104000000/1000), 1028.66, 1552.72, 700, 1166.67, 6848.724,
  1759104000000, 1759708799999, to_timestamp(1759708799999/1000),
  7696975.47834, 21299, 3672.688, 4127510.12434, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'BNBUSDT', '1w', 1760313599999, to_timestamp(1759708800000/1000), 1166.86, 1686.89, 300, 1287.45, 28021.508,
  1759708800000, 1760313599999, to_timestamp(1760313599999/1000),
  33494796.31976, 56545, 13830.241, 16563655.93214, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759319999999, to_timestamp(1759276800000/1000), 0.8364, 0.8365, 0.8335, 0.8353, 5017.9,
  1759276800000, 1759319999999, to_timestamp(1759319999999/1000),
  4190.01678, 25, 1749.8, 1460.15988, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759363199999, to_timestamp(1759320000000/1000), 0.8366, 0.8509, 0.8324, 0.8501, 163380.7,
  1759320000000, 1759363199999, to_timestamp(1759363199999/1000),
  137195.03729, 981, 87073.1, 73051.01999, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759406399999, to_timestamp(1759363200000/1000), 0.851, 0.8631, 0.848, 0.8516, 286549.9,
  1759363200000, 1759406399999, to_timestamp(1759406399999/1000),
  244800.6253, 511, 176514.9, 150806.69106, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759449599999, to_timestamp(1759406400000/1000), 0.8504, 0.8777, 0.8373, 0.8713, 344415,
  1759406400000, 1759449599999, to_timestamp(1759449599999/1000),
  296656.75327, 1922, 204023.3, 175742.81959, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759492799999, to_timestamp(1759449600000/1000), 0.8697, 0.8697, 0.8523, 0.8538, 336432.2,
  1759449600000, 1759492799999, to_timestamp(1759492799999/1000),
  288663.93487, 421, 239286.3, 205188.28335, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759535999999, to_timestamp(1759492800000/1000), 0.8537, 0.891, 0.8491, 0.8652, 758775,
  1759492800000, 1759535999999, to_timestamp(1759535999999/1000),
  657122.30912, 3033, 328199.5, 283784.48464, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759579199999, to_timestamp(1759536000000/1000), 0.8654, 0.8688, 0.8416, 0.843, 192167.7,
  1759536000000, 1759579199999, to_timestamp(1759579199999/1000),
  164381.47217, 803, 106561.2, 91122.41957, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759622399999, to_timestamp(1759579200000/1000), 0.8432, 0.8494, 0.8335, 0.8393, 71948.5,
  1759579200000, 1759622399999, to_timestamp(1759622399999/1000),
  60445.46634, 1040, 53479.9, 44952.80848, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759665599999, to_timestamp(1759622400000/1000), 0.8395, 0.8823, 0.8355, 0.8636, 384110.7,
  1759622400000, 1759665599999, to_timestamp(1759665599999/1000),
  329185.45317, 528, 158741, 136326.28075, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759708799999, to_timestamp(1759665600000/1000), 0.8631, 0.8631, 0.8273, 0.838, 109059.8,
  1759665600000, 1759708799999, to_timestamp(1759708799999/1000),
  92272.87115, 811, 65824.6, 55683.2485, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759751999999, to_timestamp(1759708800000/1000), 0.8366, 0.8547, 0.8326, 0.8511, 234016.1,
  1759708800000, 1759751999999, to_timestamp(1759751999999/1000),
  198225.87677, 307, 141095.2, 119547.83655, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759795199999, to_timestamp(1759752000000/1000), 0.8514, 0.8805, 0.8514, 0.8714, 2463768.4,
  1759752000000, 1759795199999, to_timestamp(1759795199999/1000),
  2137465.957, 1447, 1405353.4, 1219412.64958, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759838399999, to_timestamp(1759795200000/1000), 0.8715, 0.8779, 0.8488, 0.8601, 6550747.9,
  1759795200000, 1759838399999, to_timestamp(1759838399999/1000),
  5665772.37553, 543, 3303205, 2855615.08277, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759881599999, to_timestamp(1759838400000/1000), 0.8591, 0.8711, 0.8178, 0.8211, 383191.6,
  1759838400000, 1759881599999, to_timestamp(1759881599999/1000),
  320465.77295, 1149, 206323.7, 172750.04334, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759924799999, to_timestamp(1759881600000/1000), 0.8208, 0.8295, 0.8098, 0.8208, 195452.5,
  1759881600000, 1759924799999, to_timestamp(1759924799999/1000),
  159570.40662, 374, 85917.4, 70231.97301, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1759967999999, to_timestamp(1759924800000/1000), 0.8216, 0.8492, 0.814, 0.8388, 628347.8,
  1759924800000, 1759967999999, to_timestamp(1759967999999/1000),
  519421.00075, 673, 296922.7, 245673.98023, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1760011199999, to_timestamp(1759968000000/1000), 0.8394, 0.8394, 0.8025, 0.8134, 198092.4,
  1759968000000, 1760011199999, to_timestamp(1760011199999/1000),
  162053.76476, 418, 125304.8, 102477.14422, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1760054399999, to_timestamp(1760011200000/1000), 0.8126, 0.8209, 0.7951, 0.8153, 386612.7,
  1760011200000, 1760054399999, to_timestamp(1760054399999/1000),
  314146.53392, 1026, 195244.9, 158639.61907, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1760097599999, to_timestamp(1760054400000/1000), 0.8153, 0.8218, 0.8095, 0.8179, 1141216.7,
  1760054400000, 1760097599999, to_timestamp(1760097599999/1000),
  930539.08714, 355, 673975.5, 549482.30877, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1760140799999, to_timestamp(1760097600000/1000), 0.8174, 0.9549, 0.2766, 0.6344, 5659798,
  1760097600000, 1760140799999, to_timestamp(1760140799999/1000),
  3889744.12281, 3388, 2084448.1, 1550243.56125, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1760183999999, to_timestamp(1760140800000/1000), 0.6349, 0.682, 0.6228, 0.6641, 1418256.2,
  1760140800000, 1760183999999, to_timestamp(1760183999999/1000),
  928206.6791, 1314, 744435.6, 487690.74997, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1760227199999, to_timestamp(1760184000000/1000), 0.6657, 0.6661, 0.6097, 0.6313, 739549.8,
  1760184000000, 1760227199999, to_timestamp(1760227199999/1000),
  475795.62496, 1603, 367308.7, 236777.4729, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1760270399999, to_timestamp(1760227200000/1000), 0.6312, 0.651, 0.6187, 0.6427, 2275573,
  1760227200000, 1760270399999, to_timestamp(1760270399999/1000),
  1460569.15885, 1052, 1161196.4, 744988.36879, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '12h', 1760313599999, to_timestamp(1760270400000/1000), 0.644, 0.7089, 0.6374, 0.693, 1308572.6,
  1760270400000, 1760313599999, to_timestamp(1760313599999/1000),
  877103.16911, 1430, 689704.1, 462446.70346, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1759363199999, to_timestamp(1759276800000/1000), 0.8364, 0.8509, 0.8324, 0.8501, 168398.6,
  1759276800000, 1759363199999, to_timestamp(1759363199999/1000),
  141385.05407, 1006, 88822.9, 74511.17987, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1759449599999, to_timestamp(1759363200000/1000), 0.851, 0.8777, 0.8373, 0.8713, 630964.9,
  1759363200000, 1759449599999, to_timestamp(1759449599999/1000),
  541457.37857, 2433, 380538.2, 326549.51065, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1759535999999, to_timestamp(1759449600000/1000), 0.8697, 0.891, 0.8491, 0.8652, 1095207.2,
  1759449600000, 1759535999999, to_timestamp(1759535999999/1000),
  945786.24399, 3454, 567485.8, 488972.76799, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1759622399999, to_timestamp(1759536000000/1000), 0.8654, 0.8688, 0.8335, 0.8393, 264116.2,
  1759536000000, 1759622399999, to_timestamp(1759622399999/1000),
  224826.93851, 1843, 160041.1, 136075.22805, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1759708799999, to_timestamp(1759622400000/1000), 0.8395, 0.8823, 0.8273, 0.838, 493170.5,
  1759622400000, 1759708799999, to_timestamp(1759708799999/1000),
  421458.32432, 1339, 224565.6, 192009.52925, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1759795199999, to_timestamp(1759708800000/1000), 0.8366, 0.8805, 0.8326, 0.8714, 2697784.5,
  1759708800000, 1759795199999, to_timestamp(1759795199999/1000),
  2335691.83377, 1754, 1546448.6, 1338960.48613, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1759881599999, to_timestamp(1759795200000/1000), 0.8715, 0.8779, 0.8178, 0.8211, 6933939.5,
  1759795200000, 1759881599999, to_timestamp(1759881599999/1000),
  5986238.14848, 1692, 3509528.7, 3028365.12611, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1759967999999, to_timestamp(1759881600000/1000), 0.8208, 0.8492, 0.8098, 0.8388, 823800.3,
  1759881600000, 1759967999999, to_timestamp(1759967999999/1000),
  678991.40737, 1047, 382840.1, 315905.95324, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1760054399999, to_timestamp(1759968000000/1000), 0.8394, 0.8394, 0.7951, 0.8153, 584705.1,
  1759968000000, 1760054399999, to_timestamp(1760054399999/1000),
  476200.29868, 1444, 320549.7, 261116.76329, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1760140799999, to_timestamp(1760054400000/1000), 0.8153, 0.9549, 0.2766, 0.6344, 6801014.7,
  1760054400000, 1760140799999, to_timestamp(1760140799999/1000),
  4820283.20995, 3743, 2758423.6, 2099725.87002, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1760227199999, to_timestamp(1760140800000/1000), 0.6349, 0.682, 0.6097, 0.6313, 2157806,
  1760140800000, 1760227199999, to_timestamp(1760227199999/1000),
  1404002.30406, 2917, 1111744.3, 724468.22287, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1d', 1760313599999, to_timestamp(1760227200000/1000), 0.6312, 0.7089, 0.6187, 0.693, 3584145.6,
  1760227200000, 1760313599999, to_timestamp(1760313599999/1000),
  2337672.32796, 2482, 1850900.5, 1207435.07225, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '3d', 1759535999999, to_timestamp(1759276800000/1000), 0.8364, 0.891, 0.8324, 0.8652, 1894570.7,
  1759276800000, 1759535999999, to_timestamp(1759535999999/1000),
  1628628.67663, 6893, 1036846.9, 890033.45851, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '3d', 1759795199999, to_timestamp(1759536000000/1000), 0.8654, 0.8823, 0.8273, 0.8714, 3455071.2,
  1759536000000, 1759795199999, to_timestamp(1759795199999/1000),
  2981977.0966, 4936, 1931055.3, 1667045.24343, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '3d', 1760054399999, to_timestamp(1759795200000/1000), 0.8715, 0.8779, 0.7951, 0.8153, 8342444.9,
  1759795200000, 1760054399999, to_timestamp(1760054399999/1000),
  7141429.85453, 4183, 4212918.5, 3605387.84264, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '3d', 1760313599999, to_timestamp(1760054400000/1000), 0.8153, 0.9549, 0.2766, 0.693, 12542966.3,
  1760054400000, 1760313599999, to_timestamp(1760313599999/1000),
  8561957.84197, 9142, 5721068.4, 4031629.16514, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1w', 1759708799999, to_timestamp(1759104000000/1000), 0.8364, 0.891, 0.8273, 0.838, 2651857.4,
  1759104000000, 1759708799999, to_timestamp(1759708799999/1000),
  2274913.93946, 10075, 1421453.6, 1218118.21581, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'ADAUSDT', '1w', 1760313599999, to_timestamp(1759708800000/1000), 0.8366, 0.9549, 0.2766, 0.693, 23583195.7,
  1759708800000, 1760313599999, to_timestamp(1760313599999/1000),
  18039079.53027, 15079, 11480435.5, 8975977.49391, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759319999999, to_timestamp(1759276800000/1000), 0.24269, 0.24271, 0.24209, 0.24271, 13106,
  1759276800000, 1759319999999, to_timestamp(1759319999999/1000),
  3177.47834, 12, 6421, 1556.58115, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759363199999, to_timestamp(1759320000000/1000), 0.2429, 0.24894, 0.24237, 0.24894, 3140705,
  1759320000000, 1759363199999, to_timestamp(1759363199999/1000),
  769139.67202, 543, 2089491, 512005.39077, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759406399999, to_timestamp(1759363200000/1000), 0.24917, 0.26018, 0.24672, 0.25628, 481152,
  1759363200000, 1759406399999, to_timestamp(1759406399999/1000),
  122731.80715, 625, 248572, 63551.24304, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759449599999, to_timestamp(1759406400000/1000), 0.25561, 0.26383, 0.2511, 0.2618, 604984,
  1759406400000, 1759449599999, to_timestamp(1759449599999/1000),
  154783.59884, 708, 368656, 93583.42059, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759492799999, to_timestamp(1759449600000/1000), 0.26148, 0.26184, 0.25402, 0.25609, 736540,
  1759449600000, 1759492799999, to_timestamp(1759492799999/1000),
  189016.09601, 400, 305890, 78534.01289, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759535999999, to_timestamp(1759492800000/1000), 0.25575, 0.26509, 0.25397, 0.2581, 1570968,
  1759492800000, 1759535999999, to_timestamp(1759535999999/1000),
  406815.39108, 2766, 807756, 209236.66636, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759579199999, to_timestamp(1759536000000/1000), 0.258, 0.25948, 0.24866, 0.24962, 3210875,
  1759536000000, 1759579199999, to_timestamp(1759579199999/1000),
  811154.78933, 984, 1758889, 443912.55449, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759622399999, to_timestamp(1759579200000/1000), 0.24949, 0.25232, 0.24685, 0.2507, 519537,
  1759579200000, 1759622399999, to_timestamp(1759622399999/1000),
  129199.84407, 524, 215447, 53566.1814, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759665599999, to_timestamp(1759622400000/1000), 0.25095, 1.2551, 0.24969, 0.25909, 639829,
  1759622400000, 1759665599999, to_timestamp(1759665599999/1000),
  166520.08525, 1384, 311619, 81173.38576, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759708799999, to_timestamp(1759665600000/1000), 0.25866, 0.25872, 0.25112, 0.253, 549509,
  1759665600000, 1759708799999, to_timestamp(1759708799999/1000),
  140341.62748, 1100, 267101, 68241.11965, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759751999999, to_timestamp(1759708800000/1000), 0.25274, 0.26166, 0.1, 0.25997, 349090,
  1759708800000, 1759751999999, to_timestamp(1759751999999/1000),
  89079.59965, 961, 240281, 61473.75592, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759795199999, to_timestamp(1759752000000/1000), 0.26009, 0.27031, 0.23189, 0.26613, 9987919,
  1759752000000, 1759795199999, to_timestamp(1759795199999/1000),
  2637645.1065, 1330, 5147345, 1360686.91512, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759838399999, to_timestamp(1759795200000/1000), 0.2662, 0.28729, 0.23781, 0.26166, 9979635,
  1759795200000, 1759838399999, to_timestamp(1759838399999/1000),
  2618412.14388, 920, 4911483, 1292291.58523, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759881599999, to_timestamp(1759838400000/1000), 0.26165, 0.2652, 0.24654, 0.24685, 785489,
  1759838400000, 1759881599999, to_timestamp(1759881599999/1000),
  198628.77612, 1041, 437160, 110464.53932, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759924799999, to_timestamp(1759881600000/1000), 0.24677, 0.25054, 0.24353, 0.2493, 1316690,
  1759881600000, 1759924799999, to_timestamp(1759924799999/1000),
  325414.06068, 694, 686453, 169838.44284, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1759967999999, to_timestamp(1759924800000/1000), 0.24925, 0.26103, 0.24893, 0.25534, 912789,
  1759924800000, 1759967999999, to_timestamp(1759967999999/1000),
  233742.32961, 635, 469515, 120313.09496, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1760011199999, to_timestamp(1759968000000/1000), 0.2559, 0.2559, 0.24312, 0.24772, 648569,
  1759968000000, 1760011199999, to_timestamp(1760011199999/1000),
  160264.3582, 411, 370864, 91661.01756, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1760054399999, to_timestamp(1760011200000/1000), 0.24756, 0.2506, 0.24163, 0.24831, 229864,
  1760011200000, 1760054399999, to_timestamp(1760054399999/1000),
  57013.34676, 365, 57177, 14137.49427, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1760097599999, to_timestamp(1760054400000/1000), 0.24849, 0.25316, 0.2468, 0.25075, 587882,
  1760054400000, 1760097599999, to_timestamp(1760097599999/1000),
  147216.96956, 493, 286422, 71660.74673, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1760140799999, to_timestamp(1760097600000/1000), 0.25057, 0.25391, 0.09595, 0.19349, 9370977,
  1760097600000, 1760140799999, to_timestamp(1760140799999/1000),
  1449742.81143, 3475, 1834183, 254510.47035, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1760183999999, to_timestamp(1760140800000/1000), 0.19339, 0.20013, 0.18672, 0.19384, 5754759,
  1760140800000, 1760183999999, to_timestamp(1760183999999/1000),
  1118727.65291, 4126, 2092497, 406474.60812, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1760227199999, to_timestamp(1760184000000/1000), 0.19397, 0.19434, 0.17832, 0.18521, 15592458,
  1760184000000, 1760227199999, to_timestamp(1760227199999/1000),
  2959730.64535, 5071, 5267952, 1002893.65117, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1760270399999, to_timestamp(1760227200000/1000), 0.18509, 0.19097, 0.18091, 0.18872, 19165601,
  1760227200000, 1760270399999, to_timestamp(1760270399999/1000),
  3591610.40684, 5389, 5327611, 996235.12707, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '12h', 1760313599999, to_timestamp(1760270400000/1000), 0.18874, 0.21372, 0.18644, 0.20647, 3848497,
  1760270400000, 1760313599999, to_timestamp(1760313599999/1000),
  762714.80754, 1455, 1587034, 318818.82818, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1759363199999, to_timestamp(1759276800000/1000), 0.24269, 0.24894, 0.24209, 0.24894, 3153811,
  1759276800000, 1759363199999, to_timestamp(1759363199999/1000),
  772317.15036, 555, 2095912, 513561.97192, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1759449599999, to_timestamp(1759363200000/1000), 0.24917, 0.26383, 0.24672, 0.2618, 1086136,
  1759363200000, 1759449599999, to_timestamp(1759449599999/1000),
  277515.40599, 1333, 617228, 157134.66363, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1759535999999, to_timestamp(1759449600000/1000), 0.26148, 0.26509, 0.25397, 0.2581, 2307508,
  1759449600000, 1759535999999, to_timestamp(1759535999999/1000),
  595831.48709, 3166, 1113646, 287770.67925, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1759622399999, to_timestamp(1759536000000/1000), 0.258, 0.25948, 0.24685, 0.2507, 3730412,
  1759536000000, 1759622399999, to_timestamp(1759622399999/1000),
  940354.6334, 1508, 1974336, 497478.73589, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1759708799999, to_timestamp(1759622400000/1000), 0.25095, 1.2551, 0.24969, 0.253, 1189338,
  1759622400000, 1759708799999, to_timestamp(1759708799999/1000),
  306861.71273, 2484, 578720, 149414.50541, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1759795199999, to_timestamp(1759708800000/1000), 0.25274, 0.27031, 0.1, 0.26613, 10337009,
  1759708800000, 1759795199999, to_timestamp(1759795199999/1000),
  2726724.70615, 2291, 5387626, 1422160.67104, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1759881599999, to_timestamp(1759795200000/1000), 0.2662, 0.28729, 0.23781, 0.24685, 10765124,
  1759795200000, 1759881599999, to_timestamp(1759881599999/1000),
  2817040.92, 1961, 5348643, 1402756.12455, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1759967999999, to_timestamp(1759881600000/1000), 0.24677, 0.26103, 0.24353, 0.25534, 2229479,
  1759881600000, 1759967999999, to_timestamp(1759967999999/1000),
  559156.39029, 1329, 1155968, 290151.5378, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1760054399999, to_timestamp(1759968000000/1000), 0.2559, 0.2559, 0.24163, 0.24831, 878433,
  1759968000000, 1760054399999, to_timestamp(1760054399999/1000),
  217277.70496, 776, 428041, 105798.51183, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1760140799999, to_timestamp(1760054400000/1000), 0.24849, 0.25391, 0.09595, 0.19349, 9958859,
  1760054400000, 1760140799999, to_timestamp(1760140799999/1000),
  1596959.78099, 3968, 2120605, 326171.21708, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1760227199999, to_timestamp(1760140800000/1000), 0.19339, 0.20013, 0.17832, 0.18521, 21347217,
  1760140800000, 1760227199999, to_timestamp(1760227199999/1000),
  4078458.29826, 9197, 7360449, 1409368.25929, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1d', 1760313599999, to_timestamp(1760227200000/1000), 0.18509, 0.21372, 0.18091, 0.20647, 23014098,
  1760227200000, 1760313599999, to_timestamp(1760313599999/1000),
  4354325.21438, 6844, 6914645, 1315053.95525, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '3d', 1759535999999, to_timestamp(1759276800000/1000), 0.24269, 0.26509, 0.24209, 0.2581, 6547455,
  1759276800000, 1759535999999, to_timestamp(1759535999999/1000),
  1645664.04344, 5054, 3826786, 958467.3148, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '3d', 1759795199999, to_timestamp(1759536000000/1000), 0.258, 1.2551, 0.1, 0.26613, 15256759,
  1759536000000, 1759795199999, to_timestamp(1759795199999/1000),
  3973941.05228, 6283, 7940682, 2069053.91234, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '3d', 1760054399999, to_timestamp(1759795200000/1000), 0.2662, 0.28729, 0.23781, 0.24831, 13873036,
  1759795200000, 1760054399999, to_timestamp(1760054399999/1000),
  3593475.01525, 4066, 6932652, 1798706.17418, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '3d', 1760313599999, to_timestamp(1760054400000/1000), 0.24849, 0.25391, 0.09595, 0.20647, 54320174,
  1760054400000, 1760313599999, to_timestamp(1760313599999/1000),
  10029743.29363, 20009, 16395699, 3050593.43162, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1w', 1759708799999, to_timestamp(1759104000000/1000), 0.24269, 1.2551, 0.24209, 0.253, 11467205,
  1759104000000, 1759708799999, to_timestamp(1759708799999/1000),
  2892880.38957, 9046, 6379842, 1605360.5561, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOGEUSDT', '1w', 1760313599999, to_timestamp(1759708800000/1000), 0.25274, 0.28729, 0.09595, 0.20647, 78530219,
  1759708800000, 1760313599999, to_timestamp(1760313599999/1000),
  16349943.01503, 26366, 28715977, 6271460.27684, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759319999999, to_timestamp(1759276800000/1000), 2.9406, 2.9458, 2.9364, 2.9458, 2065.3,
  1759276800000, 1759319999999, to_timestamp(1759319999999/1000),
  6074.22088, 39, 505.4, 1486.30323, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759363199999, to_timestamp(1759320000000/1000), 2.9437, 2.9578, 2.9203, 2.9472, 124097.4,
  1759320000000, 1759363199999, to_timestamp(1759363199999/1000),
  364227.78262, 927, 60916.6, 178781.66685, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759406399999, to_timestamp(1759363200000/1000), 2.9493, 2.9953, 2.9403, 2.9729, 50368.7,
  1759363200000, 1759406399999, to_timestamp(1759406399999/1000),
  149629.68627, 1732, 28090.5, 83425.12388, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759449599999, to_timestamp(1759406400000/1000), 2.9716, 3.0995, 2.9483, 3.0402, 928024.7,
  1759406400000, 1759449599999, to_timestamp(1759449599999/1000),
  2800818.02741, 1207, 74390.3, 224721.43627, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759492799999, to_timestamp(1759449600000/1000), 3.0386, 3.0543, 3.0041, 3.0407, 45984.9,
  1759449600000, 1759492799999, to_timestamp(1759492799999/1000),
  139108.69862, 577, 31325.5, 94561.14238, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759535999999, to_timestamp(1759492800000/1000), 3.0375, 3.0927, 3.0102, 3.0381, 272179.8,
  1759492800000, 1759535999999, to_timestamp(1759535999999/1000),
  826753.28673, 1452, 81353.9, 247173.17505, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759579199999, to_timestamp(1759536000000/1000), 3.0402, 3.0516, 2.9839, 2.9907, 315568.6,
  1759536000000, 1759579199999, to_timestamp(1759579199999/1000),
  950480.91898, 593, 235133.1, 708486.37992, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759622399999, to_timestamp(1759579200000/1000), 2.9893, 3.0041, 2.9396, 2.9674, 114655.5,
  1759579200000, 1759622399999, to_timestamp(1759622399999/1000),
  339309.9901, 788, 77378.7, 228859.82661, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759665599999, to_timestamp(1759622400000/1000), 2.9685, 3.0708, 2.9563, 3.0227, 150700.5,
  1759622400000, 1759665599999, to_timestamp(1759665599999/1000),
  453411.06431, 597, 64999.2, 195530.34666, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759708799999, to_timestamp(1759665600000/1000), 3.0209, 3.0209, 2.9477, 2.9688, 79105.3,
  1759665600000, 1759708799999, to_timestamp(1759708799999/1000),
  236211.516, 983, 46606.1, 139097.67829, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759751999999, to_timestamp(1759708800000/1000), 2.9692, 3.0076, 2.9553, 2.9954, 107985.4,
  1759708800000, 1759751999999, to_timestamp(1759751999999/1000),
  321905.50646, 816, 49667.2, 148080.33877, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759795199999, to_timestamp(1759752000000/1000), 2.9969, 3.3476, 2.9849, 2.9891, 2519559,
  1759752000000, 1759795199999, to_timestamp(1759795199999/1000),
  7599864.1048, 2997, 1250747.2, 3775386.87606, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759838399999, to_timestamp(1759795200000/1000), 2.9881, 3.3326, 2.955, 2.9695, 1678624,
  1759795200000, 1759838399999, to_timestamp(1759838399999/1000),
  5007254.35803, 1081, 916042.5, 2730721.23023, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759881599999, to_timestamp(1759838400000/1000), 2.9696, 2.9907, 2.8489, 2.8519, 121058.3,
  1759838400000, 1759881599999, to_timestamp(1759881599999/1000),
  350134.41249, 1653, 57984.4, 167615.86942, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759924799999, to_timestamp(1759881600000/1000), 2.8521, 2.8799, 2.8344, 2.8755, 25859.1,
  1759881600000, 1759924799999, to_timestamp(1759924799999/1000),
  73952.32804, 636, 13477, 38552.56036, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1759967999999, to_timestamp(1759924800000/1000), 2.8771, 2.9243, 2.8525, 2.8774, 227693,
  1759924800000, 1759967999999, to_timestamp(1759967999999/1000),
  655657.36963, 3009, 130528.7, 375877.98137, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1760011199999, to_timestamp(1759968000000/1000), 2.8797, 2.8797, 2.7867, 2.8263, 301251.5,
  1759968000000, 1760011199999, to_timestamp(1760011199999/1000),
  853234.97604, 14100, 160995.6, 455975.46346, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1760054399999, to_timestamp(1760011200000/1000), 2.8263, 2.8407, 2.7752, 2.8022, 142954.5,
  1760011200000, 1760054399999, to_timestamp(1760054399999/1000),
  401329.71282, 1290, 60389.6, 169540.84551, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1760097599999, to_timestamp(1760054400000/1000), 2.8026, 2.8291, 2.7926, 2.8196, 99619.2,
  1760054400000, 1760097599999, to_timestamp(1760097599999/1000),
  280474.11268, 676, 55032.9, 154984.68918, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1760140799999, to_timestamp(1760097600000/1000), 2.8183, 3.0458, 1, 2.3473, 1615147.6,
  1760097600000, 1760140799999, to_timestamp(1760140799999/1000),
  3867291.46325, 4610, 619790.8, 1586635.27491, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1760183999999, to_timestamp(1760140800000/1000), 2.3691, 2.5027, 2.3073, 2.4767, 955868.7,
  1760140800000, 1760183999999, to_timestamp(1760183999999/1000),
  2346003.89436, 2979, 240912.8, 586223.49071, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1760227199999, to_timestamp(1760184000000/1000), 2.4766, 2.4916, 2.3237, 2.3817, 1659446.7,
  1760184000000, 1760227199999, to_timestamp(1760227199999/1000),
  4054775.42749, 5181, 176838.9, 429134.36061, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1760270399999, to_timestamp(1760227200000/1000), 2.382, 2.4101, 2.3129, 2.3976, 3255721.4,
  1760227200000, 1760270399999, to_timestamp(1760270399999/1000),
  7709760.34862, 5410, 1916227.6, 4539183.08221, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '12h', 1760313599999, to_timestamp(1760270400000/1000), 2.3975, 2.5822, 2.3636, 2.5248, 555251.6,
  1760270400000, 1760313599999, to_timestamp(1760313599999/1000),
  1367375.4807, 2092, 328459.4, 810586.51278, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1759363199999, to_timestamp(1759276800000/1000), 2.9406, 2.9578, 2.9203, 2.9472, 126162.7,
  1759276800000, 1759363199999, to_timestamp(1759363199999/1000),
  370302.0035, 966, 61422, 180267.97008, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1759449599999, to_timestamp(1759363200000/1000), 2.9493, 3.0995, 2.9403, 3.0402, 978393.4,
  1759363200000, 1759449599999, to_timestamp(1759449599999/1000),
  2950447.71368, 2939, 102480.8, 308146.56015, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1759535999999, to_timestamp(1759449600000/1000), 3.0386, 3.0927, 3.0041, 3.0381, 318164.7,
  1759449600000, 1759535999999, to_timestamp(1759535999999/1000),
  965861.98535, 2029, 112679.4, 341734.31743, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1759622399999, to_timestamp(1759536000000/1000), 3.0402, 3.0516, 2.9396, 2.9674, 430224.1,
  1759536000000, 1759622399999, to_timestamp(1759622399999/1000),
  1289790.90908, 1381, 312511.8, 937346.20653, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1759708799999, to_timestamp(1759622400000/1000), 2.9685, 3.0708, 2.9477, 2.9688, 229805.8,
  1759622400000, 1759708799999, to_timestamp(1759708799999/1000),
  689622.58031, 1580, 111605.3, 334628.02495, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1759795199999, to_timestamp(1759708800000/1000), 2.9692, 3.3476, 2.9553, 2.9891, 2627544.4,
  1759708800000, 1759795199999, to_timestamp(1759795199999/1000),
  7921769.61126, 3813, 1300414.4, 3923467.21483, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1759881599999, to_timestamp(1759795200000/1000), 2.9881, 3.3326, 2.8489, 2.8519, 1799682.3,
  1759795200000, 1759881599999, to_timestamp(1759881599999/1000),
  5357388.77052, 2734, 974026.9, 2898337.09965, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1759967999999, to_timestamp(1759881600000/1000), 2.8521, 2.9243, 2.8344, 2.8774, 253552.1,
  1759881600000, 1759967999999, to_timestamp(1759967999999/1000),
  729609.69767, 3645, 144005.7, 414430.54173, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1760054399999, to_timestamp(1759968000000/1000), 2.8797, 2.8797, 2.7752, 2.8022, 444206,
  1759968000000, 1760054399999, to_timestamp(1760054399999/1000),
  1254564.68886, 15390, 221385.2, 625516.30897, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1760140799999, to_timestamp(1760054400000/1000), 2.8026, 3.0458, 1, 2.3473, 1714766.8,
  1760054400000, 1760140799999, to_timestamp(1760140799999/1000),
  4147765.57593, 5286, 674823.7, 1741619.96409, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1760227199999, to_timestamp(1760140800000/1000), 2.3691, 2.5027, 2.3073, 2.3817, 2615315.4,
  1760140800000, 1760227199999, to_timestamp(1760227199999/1000),
  6400779.32185, 8160, 417751.7, 1015357.85132, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1d', 1760313599999, to_timestamp(1760227200000/1000), 2.382, 2.5822, 2.3129, 2.5248, 3810973,
  1760227200000, 1760313599999, to_timestamp(1760313599999/1000),
  9077135.82932, 7502, 2244687, 5349769.59499, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '3d', 1759535999999, to_timestamp(1759276800000/1000), 2.9406, 3.0995, 2.9203, 3.0381, 1422720.8,
  1759276800000, 1759535999999, to_timestamp(1759535999999/1000),
  4286611.70253, 5934, 276582.2, 830148.84766, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '3d', 1759795199999, to_timestamp(1759536000000/1000), 3.0402, 3.3476, 2.9396, 2.9891, 3287574.3,
  1759536000000, 1759795199999, to_timestamp(1759795199999/1000),
  9901183.10065, 6774, 1724531.5, 5195441.44631, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '3d', 1760054399999, to_timestamp(1759795200000/1000), 2.9881, 3.3326, 2.7752, 2.8022, 2497440.4,
  1759795200000, 1760054399999, to_timestamp(1760054399999/1000),
  7341563.15705, 21769, 1339417.8, 3938283.95035, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '3d', 1760313599999, to_timestamp(1760054400000/1000), 2.8026, 3.0458, 1, 2.5248, 8141055.2,
  1760054400000, 1760313599999, to_timestamp(1760313599999/1000),
  19625680.7271, 20948, 3337262.4, 8106747.4104, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1w', 1759708799999, to_timestamp(1759104000000/1000), 2.9406, 3.0995, 2.9203, 2.9688, 2082750.7,
  1759104000000, 1759708799999, to_timestamp(1759708799999/1000),
  6266025.19192, 8895, 700699.3, 2102123.07914, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'XRPUSDT', '1w', 1760313599999, to_timestamp(1759708800000/1000), 2.9692, 3.3476, 1, 2.5248, 13266040,
  1759708800000, 1760313599999, to_timestamp(1760313599999/1000),
  34889013.49541, 46530, 5977094.6, 15968498.57558, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759319999999, to_timestamp(1759276800000/1000), 4.093, 4.093, 4.079, 4.079, 591.84,
  1759276800000, 1759319999999, to_timestamp(1759319999999/1000),
  2415.40506, 10, 295.42, 1205.77756, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759363199999, to_timestamp(1759320000000/1000), 4.082, 4.122, 4.044, 4.122, 18516.32,
  1759320000000, 1759363199999, to_timestamp(1759363199999/1000),
  75617.92779, 547, 7540.55, 30740.41406, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759406399999, to_timestamp(1759363200000/1000), 4.127, 4.25, 4.1, 4.246, 5968.68,
  1759363200000, 1759406399999, to_timestamp(1759406399999/1000),
  24829.50998, 208, 2859.99, 11910.86269, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759449599999, to_timestamp(1759406400000/1000), 4.257, 4.334, 4.179, 4.309, 8033.72,
  1759406400000, 1759449599999, to_timestamp(1759449599999/1000),
  34400.61907, 219, 2385.64, 10169.47962, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759492799999, to_timestamp(1759449600000/1000), 4.306, 4.306, 4.187, 4.229, 4834.98,
  1759449600000, 1759492799999, to_timestamp(1759492799999/1000),
  20485.35679, 230, 2444.48, 10363.2102, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759535999999, to_timestamp(1759492800000/1000), 4.225, 4.364, 4.206, 4.319, 24545.27,
  1759492800000, 1759535999999, to_timestamp(1759535999999/1000),
  105392.33288, 556, 13307.33, 57408.39315, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759579199999, to_timestamp(1759536000000/1000), 4.325, 4.325, 4.194, 4.207, 20615.01,
  1759536000000, 1759579199999, to_timestamp(1759579199999/1000),
  87522.5818, 1284, 6885.42, 29184.59616, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759622399999, to_timestamp(1759579200000/1000), 4.203, 4.241, 4.144, 4.202, 29513.11,
  1759579200000, 1759622399999, to_timestamp(1759622399999/1000),
  123420.28187, 195, 13283.22, 55483.59953, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759665599999, to_timestamp(1759622400000/1000), 4.19, 4.363, 4.168, 4.267, 26401.32,
  1759622400000, 1759665599999, to_timestamp(1759665599999/1000),
  111938.67427, 190, 10025.83, 42439.40117, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759708799999, to_timestamp(1759665600000/1000), 4.244, 4.266, 4.094, 4.132, 16530.47,
  1759665600000, 1759708799999, to_timestamp(1759708799999/1000),
  69612.16792, 301, 5843.44, 24524.28123, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759751999999, to_timestamp(1759708800000/1000), 4.131, 4.228, 4.113, 4.217, 26512.71,
  1759708800000, 1759751999999, to_timestamp(1759751999999/1000),
  110462.36476, 372, 18711.04, 78075.23869, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759795199999, to_timestamp(1759752000000/1000), 4.221, 4.426, 4.221, 4.393, 41803.64,
  1759752000000, 1759795199999, to_timestamp(1759795199999/1000),
  181903.97661, 361, 20774.57, 90608.13684, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759838399999, to_timestamp(1759795200000/1000), 4.393, 4.417, 4.249, 4.322, 53103.1,
  1759795200000, 1759838399999, to_timestamp(1759838399999/1000),
  230399.06535, 622, 26666.95, 115883.36883, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759881599999, to_timestamp(1759838400000/1000), 4.33, 4.363, 4.118, 4.138, 56538.9,
  1759838400000, 1759881599999, to_timestamp(1759881599999/1000),
  235671.49175, 657, 28717.05, 119545.5271, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759924799999, to_timestamp(1759881600000/1000), 4.139, 4.182, 4.079, 4.149, 12021.42,
  1759881600000, 1759924799999, to_timestamp(1759924799999/1000),
  49662.45317, 205, 7932.8, 32779.9929, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1759967999999, to_timestamp(1759924800000/1000), 4.153, 4.239, 4.119, 4.196, 13271.98,
  1759924800000, 1759967999999, to_timestamp(1759967999999/1000),
  55671.64329, 201, 4284.29, 17943.69342, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1760011199999, to_timestamp(1759968000000/1000), 4.192, 4.192, 3.986, 4.048, 55587.88,
  1759968000000, 1760011199999, to_timestamp(1760011199999/1000),
  225474.00353, 407, 18404.46, 75088.43785, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1760054399999, to_timestamp(1760011200000/1000), 4.054, 4.1, 3.971, 4.076, 17894.22,
  1760011200000, 1760054399999, to_timestamp(1760054399999/1000),
  72028.71796, 386, 9796.81, 39489.55732, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1760097599999, to_timestamp(1760054400000/1000), 4.081, 4.332, 3.89, 4.184, 31734.43,
  1760054400000, 1760097599999, to_timestamp(1760097599999/1000),
  131194.01573, 592, 20727, 85802.51172, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1760140799999, to_timestamp(1760097600000/1000), 4.179, 4.285, 0.957, 2.95, 269318.01,
  1760097600000, 1760140799999, to_timestamp(1760140799999/1000),
  679890.93732, 2053, 116978.75, 297795.79955, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1760183999999, to_timestamp(1760140800000/1000), 2.949, 3.3, 2.886, 3.227, 53482.51,
  1760140800000, 1760183999999, to_timestamp(1760183999999/1000),
  163093.07358, 528, 27615.61, 84429.87955, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1760227199999, to_timestamp(1760184000000/1000), 3.223, 3.223, 2.905, 2.995, 28809.64,
  1760184000000, 1760227199999, to_timestamp(1760227199999/1000),
  87673.20806, 547, 12516.71, 37738.49702, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1760270399999, to_timestamp(1760227200000/1000), 2.998, 3.048, 2.91, 3.025, 46933.06,
  1760227200000, 1760270399999, to_timestamp(1760270399999/1000),
  139724.88028, 548, 30601.28, 91099.47488, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '12h', 1760313599999, to_timestamp(1760270400000/1000), 3.023, 3.302, 2.988, 3.22, 18688.22,
  1760270400000, 1760313599999, to_timestamp(1760313599999/1000),
  58887.08369, 289, 7411.55, 23213.23866, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1759363199999, to_timestamp(1759276800000/1000), 4.093, 4.122, 4.044, 4.122, 19108.16,
  1759276800000, 1759363199999, to_timestamp(1759363199999/1000),
  78033.33285, 557, 7835.97, 31946.19162, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1759449599999, to_timestamp(1759363200000/1000), 4.127, 4.334, 4.1, 4.309, 14002.4,
  1759363200000, 1759449599999, to_timestamp(1759449599999/1000),
  59230.12905, 427, 5245.63, 22080.34231, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1759535999999, to_timestamp(1759449600000/1000), 4.306, 4.364, 4.187, 4.319, 29380.25,
  1759449600000, 1759535999999, to_timestamp(1759535999999/1000),
  125877.68967, 786, 15751.81, 67771.60335, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1759622399999, to_timestamp(1759536000000/1000), 4.325, 4.325, 4.144, 4.202, 50128.12,
  1759536000000, 1759622399999, to_timestamp(1759622399999/1000),
  210942.86367, 1479, 20168.64, 84668.19569, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1759708799999, to_timestamp(1759622400000/1000), 4.19, 4.363, 4.094, 4.132, 42931.79,
  1759622400000, 1759708799999, to_timestamp(1759708799999/1000),
  181550.84219, 491, 15869.27, 66963.6824, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1759795199999, to_timestamp(1759708800000/1000), 4.131, 4.426, 4.113, 4.393, 68316.35,
  1759708800000, 1759795199999, to_timestamp(1759795199999/1000),
  292366.34137, 733, 39485.61, 168683.37553, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1759881599999, to_timestamp(1759795200000/1000), 4.393, 4.417, 4.118, 4.138, 109642,
  1759795200000, 1759881599999, to_timestamp(1759881599999/1000),
  466070.5571, 1279, 55384, 235428.89593, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1759967999999, to_timestamp(1759881600000/1000), 4.139, 4.239, 4.079, 4.196, 25293.4,
  1759881600000, 1759967999999, to_timestamp(1759967999999/1000),
  105334.09646, 406, 12217.09, 50723.68632, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1760054399999, to_timestamp(1759968000000/1000), 4.192, 4.192, 3.971, 4.076, 73482.1,
  1759968000000, 1760054399999, to_timestamp(1760054399999/1000),
  297502.72149, 793, 28201.27, 114577.99517, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1760140799999, to_timestamp(1760054400000/1000), 4.081, 4.332, 0.957, 2.95, 301052.44,
  1760054400000, 1760140799999, to_timestamp(1760140799999/1000),
  811084.95305, 2645, 137705.75, 383598.31127, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1760227199999, to_timestamp(1760140800000/1000), 2.949, 3.3, 2.886, 2.995, 82292.15,
  1760140800000, 1760227199999, to_timestamp(1760227199999/1000),
  250766.28164, 1075, 40132.32, 122168.37657, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1d', 1760313599999, to_timestamp(1760227200000/1000), 2.998, 3.302, 2.91, 3.22, 65621.28,
  1760227200000, 1760313599999, to_timestamp(1760313599999/1000),
  198611.96397, 837, 38012.83, 114312.71354, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '3d', 1759535999999, to_timestamp(1759276800000/1000), 4.093, 4.364, 4.044, 4.319, 62490.81,
  1759276800000, 1759535999999, to_timestamp(1759535999999/1000),
  263141.15157, 1770, 28833.41, 121798.13728, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '3d', 1759795199999, to_timestamp(1759536000000/1000), 4.325, 4.426, 4.094, 4.393, 161376.26,
  1759536000000, 1759795199999, to_timestamp(1759795199999/1000),
  684860.04723, 2703, 75523.52, 320315.25362, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '3d', 1760054399999, to_timestamp(1759795200000/1000), 4.393, 4.417, 3.971, 4.076, 208417.5,
  1759795200000, 1760054399999, to_timestamp(1760054399999/1000),
  868907.37505, 2478, 95802.36, 400730.57742, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '3d', 1760313599999, to_timestamp(1760054400000/1000), 4.081, 4.332, 0.957, 3.22, 448965.87,
  1760054400000, 1760313599999, to_timestamp(1760313599999/1000),
  1260463.19866, 4557, 215850.9, 620079.40138, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1w', 1759708799999, to_timestamp(1759104000000/1000), 4.093, 4.364, 4.044, 4.132, 155550.72,
  1759104000000, 1759708799999, to_timestamp(1759708799999/1000),
  655634.85743, 3740, 64871.32, 273430.01537, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'DOTUSDT', '1w', 1760313599999, to_timestamp(1759708800000/1000), 4.131, 4.426, 0.957, 3.22, 725699.72,
  1759708800000, 1760313599999, to_timestamp(1760313599999/1000),
  2421736.91508, 7768, 351138.87, 1189493.35433, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759319999999, to_timestamp(1759276800000/1000), 110.79, 110.79, 110.26, 110.27, 22.982,
  1759276800000, 1759319999999, to_timestamp(1759319999999/1000),
  2537.57866, 9, 14.84, 1638.2984, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759363199999, to_timestamp(1759320000000/1000), 110.43, 115.31, 110, 115.14, 1936.983,
  1759320000000, 1759363199999, to_timestamp(1759363199999/1000),
  216286.46234, 288, 1501.873, 167614.70105, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759406399999, to_timestamp(1759363200000/1000), 115.28, 122.63, 115.28, 119.81, 4547.929,
  1759363200000, 1759406399999, to_timestamp(1759406399999/1000),
  545879.15604, 378, 2617.743, 313976.61631, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759449599999, to_timestamp(1759406400000/1000), 119.81, 120.18, 117.51, 119.56, 5272.589,
  1759406400000, 1759449599999, to_timestamp(1759449599999/1000),
  628622.80786, 310, 898.306, 107695.41656, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759492799999, to_timestamp(1759449600000/1000), 119.3, 119.3, 115.82, 117.35, 339.663,
  1759449600000, 1759492799999, to_timestamp(1759492799999/1000),
  39851.61109, 303, 193.332, 22660.40372, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759535999999, to_timestamp(1759492800000/1000), 117.48, 124.01, 117.39, 120.47, 1496.686,
  1759492800000, 1759535999999, to_timestamp(1759535999999/1000),
  181235.83332, 987, 829.973, 100613.85732, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759579199999, to_timestamp(1759536000000/1000), 120.93, 120.93, 117.81, 117.86, 768.896,
  1759536000000, 1759579199999, to_timestamp(1759579199999/1000),
  91578.73136, 214, 271.285, 32295.08877, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759622399999, to_timestamp(1759579200000/1000), 117.93, 120.37, 117.58, 120.37, 1506.435,
  1759579200000, 1759622399999, to_timestamp(1759622399999/1000),
  179925.30162, 187, 1046.442, 125077.04485, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759665599999, to_timestamp(1759622400000/1000), 120.65, 124.09, 119.86, 120.16, 4431.82,
  1759622400000, 1759665599999, to_timestamp(1759665599999/1000),
  534349.46131, 233, 3421.575, 412482.09808, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759708799999, to_timestamp(1759665600000/1000), 119.74, 120.56, 118.38, 118.79, 4239.185,
  1759665600000, 1759708799999, to_timestamp(1759708799999/1000),
  507262.91125, 1024, 462.738, 55120.5356, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759751999999, to_timestamp(1759708800000/1000), 118.82, 121.4, 118.15, 119.97, 3047.253,
  1759708800000, 1759751999999, to_timestamp(1759751999999/1000),
  365723.96581, 1003, 1628.133, 195264.46009, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759795199999, to_timestamp(1759752000000/1000), 119.92, 121.36, 118.21, 118.36, 1478.56,
  1759752000000, 1759795199999, to_timestamp(1759795199999/1000),
  177881.69311, 303, 666.906, 80293.16517, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759838399999, to_timestamp(1759795200000/1000), 118.29, 119.23, 117.55, 118.38, 1122.408,
  1759795200000, 1759838399999, to_timestamp(1759838399999/1000),
  132621.08508, 490, 602.103, 71137.57586, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759881599999, to_timestamp(1759838400000/1000), 118.13, 119.13, 115.36, 116.96, 3189.734,
  1759838400000, 1759881599999, to_timestamp(1759881599999/1000),
  373224.98582, 461, 1901.051, 222340.09559, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759924799999, to_timestamp(1759881600000/1000), 117.11, 118.2, 115.58, 116.21, 815.595,
  1759881600000, 1759924799999, to_timestamp(1759924799999/1000),
  94586.22151, 169, 418.342, 48560.56296, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1759967999999, to_timestamp(1759924800000/1000), 116.11, 119.56, 115.96, 118.72, 1367.841,
  1759924800000, 1759967999999, to_timestamp(1759967999999/1000),
  160619.51532, 199, 579.581, 67846.39522, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1760011199999, to_timestamp(1759968000000/1000), 118.71, 119.66, 115.45, 116.4, 2553.136,
  1759968000000, 1760011199999, to_timestamp(1760011199999/1000),
  301778.63553, 286, 1417.276, 167738.18747, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1760054399999, to_timestamp(1760011200000/1000), 116.68, 131.15, 110, 125.89, 14622.91,
  1760011200000, 1760054399999, to_timestamp(1760054399999/1000),
  1818447.19591, 2315, 7438.594, 925426.83756, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1760097599999, to_timestamp(1760054400000/1000), 125.94, 132.92, 125.78, 132.44, 11418.265,
  1760054400000, 1760097599999, to_timestamp(1760097599999/1000),
  1469804.43114, 1909, 5959.968, 766986.14706, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1760140799999, to_timestamp(1760097600000/1000), 132.44, 140.84, 53.24, 96.52, 34340.249,
  1760097600000, 1760140799999, to_timestamp(1760140799999/1000),
  4230730.93901, 2204, 16978.998, 2087539.39075, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1760183999999, to_timestamp(1760140800000/1000), 96.38, 103.15, 95.09, 98.17, 4256.704,
  1760140800000, 1760183999999, to_timestamp(1760183999999/1000),
  419286.05246, 513, 2604.583, 257085.08086, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1760227199999, to_timestamp(1760184000000/1000), 97.96, 98.06, 90.12, 93.39, 2277.5,
  1760184000000, 1760227199999, to_timestamp(1760227199999/1000),
  217688.37009, 493, 978.506, 93836.6045, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1760270399999, to_timestamp(1760227200000/1000), 93.44, 96.52, 91.73, 95.61, 10311.674,
  1760227200000, 1760270399999, to_timestamp(1760270399999/1000),
  973243.44492, 464, 5339.243, 503774.67247, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '12h', 1760313599999, to_timestamp(1760270400000/1000), 95.57, 101.99, 94.25, 98.99, 2537.238,
  1760270400000, 1760313599999, to_timestamp(1760313599999/1000),
  247917.94474, 342, 1290.043, 125729.89039, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1759363199999, to_timestamp(1759276800000/1000), 110.79, 115.31, 110, 115.14, 1959.965,
  1759276800000, 1759363199999, to_timestamp(1759363199999/1000),
  218824.041, 297, 1516.713, 169252.99945, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1759449599999, to_timestamp(1759363200000/1000), 115.28, 122.63, 115.28, 119.56, 9820.518,
  1759363200000, 1759449599999, to_timestamp(1759449599999/1000),
  1174501.9639, 688, 3516.049, 421672.03287, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1759535999999, to_timestamp(1759449600000/1000), 119.3, 124.01, 115.82, 120.47, 1836.349,
  1759449600000, 1759535999999, to_timestamp(1759535999999/1000),
  221087.44441, 1290, 1023.305, 123274.26104, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1759622399999, to_timestamp(1759536000000/1000), 120.93, 120.93, 117.58, 120.37, 2275.331,
  1759536000000, 1759622399999, to_timestamp(1759622399999/1000),
  271504.03298, 401, 1317.727, 157372.13362, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1759708799999, to_timestamp(1759622400000/1000), 120.65, 124.09, 118.38, 118.79, 8671.005,
  1759622400000, 1759708799999, to_timestamp(1759708799999/1000),
  1041612.37256, 1257, 3884.313, 467602.63368, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1759795199999, to_timestamp(1759708800000/1000), 118.82, 121.4, 118.15, 118.36, 4525.813,
  1759708800000, 1759795199999, to_timestamp(1759795199999/1000),
  543605.65892, 1306, 2295.039, 275557.62526, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1759881599999, to_timestamp(1759795200000/1000), 118.29, 119.23, 115.36, 116.96, 4312.142,
  1759795200000, 1759881599999, to_timestamp(1759881599999/1000),
  505846.0709, 951, 2503.154, 293477.67145, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1759967999999, to_timestamp(1759881600000/1000), 117.11, 119.56, 115.58, 118.72, 2183.436,
  1759881600000, 1759967999999, to_timestamp(1759967999999/1000),
  255205.73683, 368, 997.923, 116406.95818, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1760054399999, to_timestamp(1759968000000/1000), 118.71, 131.15, 110, 125.89, 17176.046,
  1759968000000, 1760054399999, to_timestamp(1760054399999/1000),
  2120225.83144, 2601, 8855.87, 1093165.02503, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1760140799999, to_timestamp(1760054400000/1000), 125.94, 140.84, 53.24, 96.52, 45758.514,
  1760054400000, 1760140799999, to_timestamp(1760140799999/1000),
  5700535.37015, 4113, 22938.966, 2854525.53781, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1760227199999, to_timestamp(1760140800000/1000), 96.38, 103.15, 90.12, 93.39, 6534.204,
  1760140800000, 1760227199999, to_timestamp(1760227199999/1000),
  636974.42255, 1006, 3583.089, 350921.68536, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1d', 1760313599999, to_timestamp(1760227200000/1000), 93.44, 101.99, 91.73, 98.99, 12848.912,
  1760227200000, 1760313599999, to_timestamp(1760313599999/1000),
  1221161.38966, 806, 6629.286, 629504.56286, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '3d', 1759535999999, to_timestamp(1759276800000/1000), 110.79, 124.01, 110, 120.47, 13616.832,
  1759276800000, 1759535999999, to_timestamp(1759535999999/1000),
  1614413.44931, 2275, 6056.067, 714199.29336, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '3d', 1759795199999, to_timestamp(1759536000000/1000), 120.93, 124.09, 117.58, 118.36, 15472.149,
  1759536000000, 1759795199999, to_timestamp(1759795199999/1000),
  1856722.06446, 2964, 7497.079, 900532.39256, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '3d', 1760054399999, to_timestamp(1759795200000/1000), 118.29, 131.15, 110, 125.89, 23671.624,
  1759795200000, 1760054399999, to_timestamp(1760054399999/1000),
  2881277.63917, 3920, 12356.947, 1503049.65466, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '3d', 1760313599999, to_timestamp(1760054400000/1000), 125.94, 140.84, 53.24, 98.99, 65141.63,
  1760054400000, 1760313599999, to_timestamp(1760313599999/1000),
  7558671.18236, 5925, 33151.341, 3834951.78603, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1w', 1759708799999, to_timestamp(1759104000000/1000), 110.79, 124.09, 110, 118.79, 24563.168,
  1759104000000, 1759708799999, to_timestamp(1759708799999/1000),
  2927529.85485, 3933, 11258.107, 1339174.06066, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LTCUSDT', '1w', 1760313599999, to_timestamp(1759708800000/1000), 118.82, 140.84, 53.24, 98.99, 93339.067,
  1759708800000, 1760313599999, to_timestamp(1760313599999/1000),
  10983554.48045, 11151, 47803.327, 5613559.06595, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759319999999, to_timestamp(1759276800000/1000), 22.23, 22.24, 22.14, 22.21, 115.87,
  1759276800000, 1759319999999, to_timestamp(1759319999999/1000),
  2570.2535, 11, 71.66, 1589.4438, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759363199999, to_timestamp(1759320000000/1000), 22.25, 22.62, 22.13, 22.56, 1746.05,
  1759320000000, 1759363199999, to_timestamp(1759363199999/1000),
  39055.141, 382, 859.78, 19240.2905, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759406399999, to_timestamp(1759363200000/1000), 22.57, 22.82, 22.43, 22.49, 466.21,
  1759363200000, 1759406399999, to_timestamp(1759406399999/1000),
  10535.1395, 125, 250.64, 5672.0276, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759449599999, to_timestamp(1759406400000/1000), 22.42, 23.13, 21.96, 22.78, 7482.7,
  1759406400000, 1759449599999, to_timestamp(1759449599999/1000),
  168418.2273, 227, 1250.61, 28614.5757, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759492799999, to_timestamp(1759449600000/1000), 22.78, 22.86, 22.26, 22.27, 1306.67,
  1759449600000, 1759492799999, to_timestamp(1759492799999/1000),
  29248.6006, 440, 797.75, 17854.1395, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759535999999, to_timestamp(1759492800000/1000), 22.27, 23.07, 22.18, 22.5, 2046.82,
  1759492800000, 1759535999999, to_timestamp(1759535999999/1000),
  45978.8141, 450, 1293.98, 29126.4806, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759579199999, to_timestamp(1759536000000/1000), 22.5, 22.59, 21.79, 21.85, 2198.69,
  1759536000000, 1759579199999, to_timestamp(1759579199999/1000),
  48689.685, 203, 1670.43, 37047.6319, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759622399999, to_timestamp(1759579200000/1000), 21.86, 22.14, 21.82, 22.02, 713.17,
  1759579200000, 1759622399999, to_timestamp(1759622399999/1000),
  15658.4144, 108, 138.73, 3049.6064, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759665599999, to_timestamp(1759622400000/1000), 22.09, 22.91, 21.94, 22.75, 7604.13,
  1759622400000, 1759665599999, to_timestamp(1759665599999/1000),
  170211.5602, 108, 3040.04, 68300.2844, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759708799999, to_timestamp(1759665600000/1000), 22.75, 22.75, 21.91, 22.05, 839.7,
  1759665600000, 1759708799999, to_timestamp(1759708799999/1000),
  18785.4909, 141, 284.71, 6316.5213, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759751999999, to_timestamp(1759708800000/1000), 22.08, 22.23, 21.53, 22.14, 573.51,
  1759708800000, 1759751999999, to_timestamp(1759751999999/1000),
  12609.6008, 171, 266.28, 5841.4145, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759795199999, to_timestamp(1759752000000/1000), 22.13, 23.54, 22.13, 23.37, 1739.53,
  1759752000000, 1759795199999, to_timestamp(1759795199999/1000),
  39691.736, 206, 833.75, 18890.9954, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759838399999, to_timestamp(1759795200000/1000), 23.45, 23.69, 22.59, 22.83, 4592.87,
  1759795200000, 1759838399999, to_timestamp(1759838399999/1000),
  104800.8988, 214, 1124.71, 25814.4536, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759881599999, to_timestamp(1759838400000/1000), 22.84, 23.07, 21.8, 21.8, 2593.77,
  1759838400000, 1759881599999, to_timestamp(1759881599999/1000),
  57409.7275, 261, 2239.5, 49588.7963, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759924799999, to_timestamp(1759881600000/1000), 21.79, 22.14, 21.69, 22.05, 6217.33,
  1759881600000, 1759924799999, to_timestamp(1759924799999/1000),
  136450.2525, 164, 705.47, 15447.9075, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1759967999999, to_timestamp(1759924800000/1000), 22.07, 22.65, 21.93, 22.63, 3351.9,
  1759924800000, 1759967999999, to_timestamp(1759967999999/1000),
  75013.1219, 138, 1343.99, 30008.4592, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1760011199999, to_timestamp(1759968000000/1000), 22.66, 22.66, 21.61, 21.73, 1312.87,
  1759968000000, 1760011199999, to_timestamp(1760011199999/1000),
  28856.1545, 129, 807.18, 17629.1839, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1760054399999, to_timestamp(1760011200000/1000), 21.73, 22.11, 21.37, 21.99, 3837.52,
  1760011200000, 1760054399999, to_timestamp(1760054399999/1000),
  83218.1405, 422, 1905.64, 41206.917, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1760097599999, to_timestamp(1760054400000/1000), 22, 22.73, 22, 22.42, 1416.53,
  1760054400000, 1760097599999, to_timestamp(1760097599999/1000),
  31714.5817, 118, 600.44, 13439.2358, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1760140799999, to_timestamp(1760097600000/1000), 22.41, 22.61, 8.19, 17.2, 197749.51,
  1760097600000, 1760140799999, to_timestamp(1760140799999/1000),
  2914632.8557, 1008, 41890.99, 452124.5394, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1760183999999, to_timestamp(1760140800000/1000), 17.33, 18.5, 16.96, 18.01, 6353.38,
  1760140800000, 1760183999999, to_timestamp(1760183999999/1000),
  113517.7502, 867, 3069.92, 54578.7103, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1760227199999, to_timestamp(1760184000000/1000), 18.05, 18.14, 16.64, 17.2, 12639.13,
  1760184000000, 1760227199999, to_timestamp(1760227199999/1000),
  222428.2662, 759, 6286.01, 110949.9359, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1760270399999, to_timestamp(1760227200000/1000), 17.16, 17.54, 16.7, 17.4, 4907.13,
  1760227200000, 1760270399999, to_timestamp(1760270399999/1000),
  84120.1183, 281, 2869.69, 48856.097, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '12h', 1760313599999, to_timestamp(1760270400000/1000), 17.4, 19.39, 17.28, 18.91, 11649.9,
  1760270400000, 1760313599999, to_timestamp(1760313599999/1000),
  214256.7629, 445, 6087.06, 111911.7525, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1759363199999, to_timestamp(1759276800000/1000), 22.23, 22.62, 22.13, 22.56, 1861.92,
  1759276800000, 1759363199999, to_timestamp(1759363199999/1000),
  41625.3945, 393, 931.44, 20829.7343, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1759449599999, to_timestamp(1759363200000/1000), 22.57, 23.13, 21.96, 22.78, 7948.91,
  1759363200000, 1759449599999, to_timestamp(1759449599999/1000),
  178953.3668, 352, 1501.25, 34286.6033, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1759535999999, to_timestamp(1759449600000/1000), 22.78, 23.07, 22.18, 22.5, 3353.49,
  1759449600000, 1759535999999, to_timestamp(1759535999999/1000),
  75227.4147, 890, 2091.73, 46980.6201, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1759622399999, to_timestamp(1759536000000/1000), 22.5, 22.59, 21.79, 22.02, 2911.86,
  1759536000000, 1759622399999, to_timestamp(1759622399999/1000),
  64348.0994, 311, 1809.16, 40097.2383, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1759708799999, to_timestamp(1759622400000/1000), 22.09, 22.91, 21.91, 22.05, 8443.83,
  1759622400000, 1759708799999, to_timestamp(1759708799999/1000),
  188997.0511, 249, 3324.75, 74616.8057, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1759795199999, to_timestamp(1759708800000/1000), 22.08, 23.54, 21.53, 23.37, 2313.04,
  1759708800000, 1759795199999, to_timestamp(1759795199999/1000),
  52301.3368, 377, 1100.03, 24732.4099, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1759881599999, to_timestamp(1759795200000/1000), 23.45, 23.69, 21.8, 21.8, 7186.64,
  1759795200000, 1759881599999, to_timestamp(1759881599999/1000),
  162210.6263, 475, 3364.21, 75403.2499, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1759967999999, to_timestamp(1759881600000/1000), 21.79, 22.65, 21.69, 22.63, 9569.23,
  1759881600000, 1759967999999, to_timestamp(1759967999999/1000),
  211463.3744, 302, 2049.46, 45456.3667, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1760054399999, to_timestamp(1759968000000/1000), 22.66, 22.66, 21.37, 21.99, 5150.39,
  1759968000000, 1760054399999, to_timestamp(1760054399999/1000),
  112074.295, 551, 2712.82, 58836.1009, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1760140799999, to_timestamp(1760054400000/1000), 22, 22.73, 8.19, 17.2, 199166.04,
  1760054400000, 1760140799999, to_timestamp(1760140799999/1000),
  2946347.4374, 1126, 42491.43, 465563.7752, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1760227199999, to_timestamp(1760140800000/1000), 17.33, 18.5, 16.64, 17.2, 18992.51,
  1760140800000, 1760227199999, to_timestamp(1760227199999/1000),
  335946.0164, 1626, 9355.93, 165528.6462, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1d', 1760313599999, to_timestamp(1760227200000/1000), 17.16, 19.39, 16.7, 18.91, 16557.03,
  1760227200000, 1760313599999, to_timestamp(1760313599999/1000),
  298376.8812, 726, 8956.75, 160767.8495, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '3d', 1759535999999, to_timestamp(1759276800000/1000), 22.23, 23.13, 21.96, 22.5, 13164.32,
  1759276800000, 1759535999999, to_timestamp(1759535999999/1000),
  295806.176, 1635, 4524.42, 102096.9577, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '3d', 1759795199999, to_timestamp(1759536000000/1000), 22.5, 23.54, 21.53, 23.37, 13668.73,
  1759536000000, 1759795199999, to_timestamp(1759795199999/1000),
  305646.4873, 937, 6233.94, 139446.4539, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '3d', 1760054399999, to_timestamp(1759795200000/1000), 23.45, 23.69, 21.37, 21.99, 21906.26,
  1759795200000, 1760054399999, to_timestamp(1760054399999/1000),
  485748.2957, 1328, 8126.49, 179695.7175, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '3d', 1760313599999, to_timestamp(1760054400000/1000), 22, 22.73, 8.19, 18.91, 234715.58,
  1760054400000, 1760313599999, to_timestamp(1760313599999/1000),
  3580670.335, 3478, 60804.11, 791860.2709, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1w', 1759708799999, to_timestamp(1759104000000/1000), 22.23, 23.13, 21.79, 22.05, 24520.01,
  1759104000000, 1759708799999, to_timestamp(1759708799999/1000),
  549151.3265, 2195, 9658.33, 216811.0017, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'LINKUSDT', '1w', 1760313599999, to_timestamp(1759708800000/1000), 22.08, 23.69, 8.19, 18.91, 258934.88,
  1759708800000, 1760313599999, to_timestamp(1760313599999/1000),
  4118719.9675, 5183, 70030.63, 996288.3983, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759319999999, to_timestamp(1759276800000/1000), 7.867, 7.87, 7.853, 7.864, 253.85,
  1759276800000, 1759319999999, to_timestamp(1759319999999/1000),
  1995.46313, 6, 190.27, 1495.46809, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759363199999, to_timestamp(1759320000000/1000), 7.873, 8.08, 7.831, 8.047, 1410.86,
  1759320000000, 1759363199999, to_timestamp(1759363199999/1000),
  11232.1057, 56, 125.83, 1004.25486, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759406399999, to_timestamp(1759363200000/1000), 8.055, 8.26, 8.027, 8.201, 711.35,
  1759363200000, 1759406399999, to_timestamp(1759406399999/1000),
  5804.51249, 65, 271.34, 2214.14465, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759449599999, to_timestamp(1759406400000/1000), 8.198, 8.375, 8.148, 8.361, 2123.98,
  1759406400000, 1759449599999, to_timestamp(1759449599999/1000),
  17670.99908, 87, 388.75, 3214.37573, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759492799999, to_timestamp(1759449600000/1000), 8.308, 9.134, 8.205, 8.222, 8041.05,
  1759449600000, 1759492799999, to_timestamp(1759492799999/1000),
  66327.84394, 65, 963.46, 7986.2131, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759535999999, to_timestamp(1759492800000/1000), 8.216, 8.476, 8.176, 8.179, 1936.5,
  1759492800000, 1759535999999, to_timestamp(1759535999999/1000),
  16070.77398, 195, 1055.99, 8743.27547, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759579199999, to_timestamp(1759536000000/1000), 8.198, 8.984, 7.945, 7.945, 1772.95,
  1759536000000, 1759579199999, to_timestamp(1759579199999/1000),
  14435.17167, 132, 982.95, 7991.81439, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759622399999, to_timestamp(1759579200000/1000), 7.947, 8.012, 7.927, 7.985, 460.75,
  1759579200000, 1759622399999, to_timestamp(1759622399999/1000),
  3668.70224, 52, 211.02, 1679.42361, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759665599999, to_timestamp(1759622400000/1000), 8.063, 8.767, 7.975, 8.251, 892.49,
  1759622400000, 1759665599999, to_timestamp(1759665599999/1000),
  7375.07236, 190, 287.95, 2359.85781, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759708799999, to_timestamp(1759665600000/1000), 8.296, 8.296, 8.016, 8.056, 785.21,
  1759665600000, 1759708799999, to_timestamp(1759708799999/1000),
  6387.86165, 99, 297.15, 2407.40003, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759751999999, to_timestamp(1759708800000/1000), 8.045, 8.293, 8.027, 8.274, 1488.88,
  1759708800000, 1759751999999, to_timestamp(1759751999999/1000),
  12190.96102, 164, 897.47, 7338.29698, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759795199999, to_timestamp(1759752000000/1000), 8.289, 8.441, 8.285, 8.36, 680.44,
  1759752000000, 1759795199999, to_timestamp(1759795199999/1000),
  5703.41702, 50, 211.55, 1778.13375, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759838399999, to_timestamp(1759795200000/1000), 8.362, 8.471, 8.022, 8.131, 9970,
  1759795200000, 1759838399999, to_timestamp(1759838399999/1000),
  81326.74698, 202, 5537.76, 45288.03474, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759881599999, to_timestamp(1759838400000/1000), 8.113, 8.2, 7.72, 7.77, 6084.09,
  1759838400000, 1759881599999, to_timestamp(1759881599999/1000),
  47902.89665, 145, 3318.09, 26254.08472, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759924799999, to_timestamp(1759881600000/1000), 7.769, 8.367, 7.708, 7.794, 4001.75,
  1759881600000, 1759924799999, to_timestamp(1759924799999/1000),
  31059.06901, 91, 1805.35, 14058.69758, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1759967999999, to_timestamp(1759924800000/1000), 7.823, 8.105, 7.797, 8.066, 4193.42,
  1759924800000, 1759967999999, to_timestamp(1759967999999/1000),
  33297.5068, 98, 1789.63, 14161.46608, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1760011199999, to_timestamp(1759968000000/1000), 8.04, 8.217, 7.708, 7.832, 3868.51,
  1759968000000, 1760011199999, to_timestamp(1760011199999/1000),
  30066.97446, 164, 3484.19, 27036.14289, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1760054399999, to_timestamp(1760011200000/1000), 7.853, 7.909, 7.701, 7.86, 1701.57,
  1760011200000, 1760054399999, to_timestamp(1760054399999/1000),
  13359.8255, 106, 259.22, 2018.85998, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1760097599999, to_timestamp(1760054400000/1000), 7.858, 8.581, 7.858, 8.17, 6773.98,
  1760054400000, 1760097599999, to_timestamp(1760097599999/1000),
  56817.6295, 370, 2511.06, 21301.4701, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1760140799999, to_timestamp(1760097600000/1000), 8.143, 8.276, 2.327, 5.818, 212706.27,
  1760097600000, 1760140799999, to_timestamp(1760140799999/1000),
  1021827.2009, 490, 75223.24, 387450.23952, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1760183999999, to_timestamp(1760140800000/1000), 5.815, 6.108, 5.593, 6.027, 14040.71,
  1760140800000, 1760183999999, to_timestamp(1760183999999/1000),
  83849.39959, 119, 7855.68, 46925.08926, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1760227199999, to_timestamp(1760184000000/1000), 6.013, 6.116, 5.663, 5.839, 19949.7,
  1760184000000, 1760227199999, to_timestamp(1760227199999/1000),
  118933.61552, 322, 9847.03, 58744.70224, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1760270399999, to_timestamp(1760227200000/1000), 5.855, 6.186, 5.804, 6.081, 7860.79,
  1760227200000, 1760270399999, to_timestamp(1760270399999/1000),
  47579.09182, 251, 5376.91, 32610.66672, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '12h', 1760313599999, to_timestamp(1760270400000/1000), 6.086, 6.696, 6.073, 6.629, 31354.29,
  1760270400000, 1760313599999, to_timestamp(1760313599999/1000),
  198059.15972, 172, 15179.58, 96247.05182, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1759363199999, to_timestamp(1759276800000/1000), 7.867, 8.08, 7.831, 8.047, 1664.71,
  1759276800000, 1759363199999, to_timestamp(1759363199999/1000),
  13227.56883, 62, 316.1, 2499.72295, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1759449599999, to_timestamp(1759363200000/1000), 8.055, 8.375, 8.027, 8.361, 2835.33,
  1759363200000, 1759449599999, to_timestamp(1759449599999/1000),
  23475.51157, 152, 660.09, 5428.52038, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1759535999999, to_timestamp(1759449600000/1000), 8.308, 9.134, 8.176, 8.179, 9977.55,
  1759449600000, 1759535999999, to_timestamp(1759535999999/1000),
  82398.61792, 260, 2019.45, 16729.48857, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1759622399999, to_timestamp(1759536000000/1000), 8.198, 8.984, 7.927, 7.985, 2233.7,
  1759536000000, 1759622399999, to_timestamp(1759622399999/1000),
  18103.87391, 184, 1193.97, 9671.238, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1759708799999, to_timestamp(1759622400000/1000), 8.063, 8.767, 7.975, 8.056, 1677.7,
  1759622400000, 1759708799999, to_timestamp(1759708799999/1000),
  13762.93401, 289, 585.1, 4767.25784, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1759795199999, to_timestamp(1759708800000/1000), 8.045, 8.441, 8.027, 8.36, 2169.32,
  1759708800000, 1759795199999, to_timestamp(1759795199999/1000),
  17894.37804, 214, 1109.02, 9116.43073, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1759881599999, to_timestamp(1759795200000/1000), 8.362, 8.471, 7.72, 7.77, 16054.09,
  1759795200000, 1759881599999, to_timestamp(1759881599999/1000),
  129229.64363, 347, 8855.85, 71542.11946, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1759967999999, to_timestamp(1759881600000/1000), 7.769, 8.367, 7.708, 8.066, 8195.17,
  1759881600000, 1759967999999, to_timestamp(1759967999999/1000),
  64356.57581, 189, 3594.98, 28220.16366, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1760054399999, to_timestamp(1759968000000/1000), 8.04, 8.217, 7.701, 7.86, 5570.08,
  1759968000000, 1760054399999, to_timestamp(1760054399999/1000),
  43426.79996, 270, 3743.41, 29055.00287, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1760140799999, to_timestamp(1760054400000/1000), 7.858, 8.581, 2.327, 5.818, 219480.25,
  1760054400000, 1760140799999, to_timestamp(1760140799999/1000),
  1078644.8304, 860, 77734.3, 408751.70962, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1760227199999, to_timestamp(1760140800000/1000), 5.815, 6.116, 5.593, 5.839, 33990.41,
  1760140800000, 1760227199999, to_timestamp(1760227199999/1000),
  202783.01511, 441, 17702.71, 105669.7915, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1d', 1760313599999, to_timestamp(1760227200000/1000), 5.855, 6.696, 5.804, 6.629, 39215.08,
  1760227200000, 1760313599999, to_timestamp(1760313599999/1000),
  245638.25154, 423, 20556.49, 128857.71854, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '3d', 1759535999999, to_timestamp(1759276800000/1000), 7.867, 9.134, 7.831, 8.179, 14477.59,
  1759276800000, 1759535999999, to_timestamp(1759535999999/1000),
  119101.69832, 474, 2995.64, 24657.7319, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '3d', 1759795199999, to_timestamp(1759536000000/1000), 8.198, 8.984, 7.927, 8.36, 6080.72,
  1759536000000, 1759795199999, to_timestamp(1759795199999/1000),
  49761.18596, 687, 2888.09, 23554.92657, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '3d', 1760054399999, to_timestamp(1759795200000/1000), 8.362, 8.471, 7.701, 7.86, 29819.34,
  1759795200000, 1760054399999, to_timestamp(1760054399999/1000),
  237013.0194, 806, 16194.24, 128817.28599, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '3d', 1760313599999, to_timestamp(1760054400000/1000), 7.858, 8.581, 2.327, 6.629, 292685.74,
  1760054400000, 1760313599999, to_timestamp(1760313599999/1000),
  1527066.09705, 1724, 115993.5, 643279.21966, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1w', 1759708799999, to_timestamp(1759104000000/1000), 7.867, 9.134, 7.831, 8.056, 18388.99,
  1759104000000, 1759708799999, to_timestamp(1759708799999/1000),
  150968.50624, 947, 4774.71, 39096.22774, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
INSERT INTO kline (
  symbol, interval, timestamp, display_time, open, high, low, close, volume,
  open_time, close_time, display_close_time,
  quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
) VALUES (
  'UNIUSDT', '1w', 1760313599999, to_timestamp(1759708800000/1000), 8.045, 8.581, 2.327, 6.629, 324674.4,
  1759708800000, 1760313599999, to_timestamp(1760313599999/1000),
  1781973.49449, 2744, 133296.76, 781212.93638, '0'
) ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;
