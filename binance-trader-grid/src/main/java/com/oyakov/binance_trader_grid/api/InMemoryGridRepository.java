package com.oyakov.binance_trader_grid.api;

import com.oyakov.binance_trader_grid.grid.*;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/** Simple in-memory grid strategy repository for early API work. */
public class InMemoryGridRepository {
    private final Map<String, GridStrategy> byId = new ConcurrentHashMap<>();
    private final Set<String> active = Collections.newSetFromMap(new ConcurrentHashMap<>());

    public List<GridStrategy> list() {
        return new ArrayList<>(byId.values());
    }

    public Optional<GridStrategy> get(String id) { return Optional.ofNullable(byId.get(id)); }

    public GridStrategy save(GridStrategy s) {
        byId.put(s.id(), s);
        return s;
    }

    public boolean activate(String id) { return byId.containsKey(id) && active.add(id); }
    public boolean deactivate(String id) { return active.remove(id); }
    public boolean isActive(String id) { return active.contains(id); }
}


