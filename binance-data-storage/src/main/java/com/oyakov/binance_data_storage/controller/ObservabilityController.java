package com.oyakov.binance_data_storage.controller;

import com.oyakov.binance_data_storage.service.ObservabilityService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * REST controller for observability metrics
 */
@RestController
@RequestMapping("/api/v1/observability")
@RequiredArgsConstructor
@Slf4j
public class ObservabilityController {

    private final ObservabilityService observabilityService;

    @PostMapping("/strategy-analysis")
    public ResponseEntity<Void> recordStrategyAnalysis(@RequestBody Map<String, Object> data) {
        try {
            observabilityService.recordStrategyAnalysis(data);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Failed to record strategy analysis", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping("/decision-log")
    public ResponseEntity<Void> recordDecisionLog(@RequestBody Map<String, Object> data) {
        try {
            observabilityService.recordDecisionLog(data);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Failed to record decision log", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping("/portfolio-snapshot")
    public ResponseEntity<Void> recordPortfolioSnapshot(@RequestBody Map<String, Object> data) {
        try {
            observabilityService.recordPortfolioSnapshot(data);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Failed to record portfolio snapshot", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}

