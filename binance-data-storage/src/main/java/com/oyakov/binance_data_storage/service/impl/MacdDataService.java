package com.oyakov.binance_data_storage.service.impl;

import com.oyakov.binance_data_storage.model.macd.MacdItem;
import com.oyakov.binance_data_storage.repository.jpa.MacdPostgresRepository;
import com.oyakov.binance_data_storage.service.api.MacdDataServiceApi;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Log4j2
public class MacdDataService implements MacdDataServiceApi {

    private final MacdPostgresRepository macdPostgresRepository;

    @Override
    @Transactional
    public void upsert(MacdItem item) {
        log.info("Upserting MACD item: {} {} ts {}", item.getSymbol(), item.getInterval(), item.getTimestamp());
        macdPostgresRepository.upsertMacd(
                item.getSymbol(),
                item.getInterval(),
                item.getTimestamp(),
                item.getCollection_time(),
                item.getDisplay_time(),
                item.getEma_fast(),
                item.getEma_slow(),
                item.getMacd(),
                item.getSignal(),
                item.getHistogram(),
                item.getSignal_buy(),
                item.getSignal_sell(),
                item.getVolume_signal(),
                item.getBuy(),
                item.getSell()
        );
    }
}


