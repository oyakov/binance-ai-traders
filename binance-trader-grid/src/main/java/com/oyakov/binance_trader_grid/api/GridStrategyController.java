package com.oyakov.binance_trader_grid.api;

import com.oyakov.binance_trader_grid.api.dto.GridStrategyDto;
import com.oyakov.binance_trader_grid.grid.*;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/grid/strategies")
@ConditionalOnProperty(prefix = "grid.api", name = "enabled", havingValue = "true")
public class GridStrategyController {
    private final InMemoryGridRepository repo;

    public GridStrategyController(InMemoryGridRepository repo) { this.repo = repo; }

    @GetMapping
    public List<GridStrategyDto> list() {
        return repo.list().stream().map(this::toDto).toList();
    }

    @PostMapping
    public ResponseEntity<GridStrategyDto> create(@RequestBody GridStrategyDto dto) {
        String id = dto.id != null && !dto.id.isBlank() ? dto.id : UUID.randomUUID().toString();
        GridStrategy s = fromDto(id, dto);
        repo.save(s);
        return ResponseEntity.created(URI.create("/api/grid/strategies/" + id)).body(toDto(s));
    }

    @PutMapping("/{id}")
    public ResponseEntity<GridStrategyDto> update(@PathVariable String id, @RequestBody GridStrategyDto dto) {
        GridStrategy s = fromDto(id, dto);
        repo.save(s);
        return ResponseEntity.ok(toDto(s));
    }

    @PostMapping("/{id}/activate")
    public ResponseEntity<Void> activate(@PathVariable String id) {
        return repo.activate(id) ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
    }

    @PostMapping("/{id}/deactivate")
    public ResponseEntity<Void> deactivate(@PathVariable String id) {
        return repo.deactivate(id) ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
    }

    private GridStrategy fromDto(String id, GridStrategyDto dto) {
        PriceRange range = new PriceRange(dto.lower, dto.upper);
        GridPlan plan = new GridPlan(range, dto.levels, dto.baseOrderSize);
        RiskLimits risk = new RiskLimits(dto.dailyLossLimitPct, dto.maxPositionSizeQuote);
        return new GridStrategy(id, dto.symbol, dto.interval, plan, risk);
    }

    private GridStrategyDto toDto(GridStrategy s) {
        GridStrategyDto dto = new GridStrategyDto();
        dto.id = s.id();
        dto.symbol = s.symbol();
        dto.interval = s.interval();
        dto.lower = s.plan().range().lower();
        dto.upper = s.plan().range().upper();
        dto.levels = s.plan().count();
        dto.baseOrderSize = s.plan().levels().isEmpty() ? 0 : s.plan().levels().get(0).quantity();
        dto.dailyLossLimitPct = s.risk().dailyLossLimitPct();
        dto.maxPositionSizeQuote = s.risk().maxPositionSizeQuote();
        dto.active = repo.isActive(s.id());
        return dto;
    }
}


