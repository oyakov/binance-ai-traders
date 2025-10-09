package com.oyakov.binance_data_storage.controller;

import com.oyakov.binance_data_storage.model.macd.MacdItem;
import com.oyakov.binance_data_storage.service.api.MacdDataServiceApi;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.oyakov.binance_data_storage.repository.jpa.MacdPostgresRepository;

import java.util.List;

@RestController
@RequestMapping("/api/v1/macd")
@RequiredArgsConstructor
@Log4j2
public class MacdController {

    private final MacdDataServiceApi macdDataService;
    private final MacdPostgresRepository macdRepo;

    @PostMapping
    public ResponseEntity<Void> upsert(@RequestBody MacdItem item) {
        try {
            macdDataService.upsert(item);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Failed to upsert MACD item", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/recent")
    public ResponseEntity<List<MacdItem>> recent(@RequestParam String symbol,
                                                 @RequestParam String interval,
                                                 @RequestParam(defaultValue = "100") int limit) {
        try {
            int capped = Math.min(Math.max(limit, 1), 1000);
            return ResponseEntity.ok(macdRepo.findRecentMacd(symbol.toUpperCase(), interval, capped));
        } catch (Exception e) {
            log.error("Failed to fetch recent MACD items", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}


