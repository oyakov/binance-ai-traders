package com.oyakov.binance_trader_grid.grid;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Deterministic plan of grid levels computed from range and count.
 */
public final class GridPlan {
    private final PriceRange range;
    private final int levels;
    private final List<GridLevel> gridLevels;

    public GridPlan(PriceRange range, int levels, double baseOrderSize) {
        if (levels < 2) throw new IllegalArgumentException("levels >= 2 required");
        this.range = range;
        this.levels = levels;
        this.gridLevels = build(range, levels, baseOrderSize);
    }

    private static List<GridLevel> build(PriceRange range, int levels, double qty) {
        double step = range.width() / (levels - 1);
        List<GridLevel> list = new ArrayList<>(levels);
        for (int i = 0; i < levels; i++) {
            double price = range.lower() + step * i;
            list.add(new GridLevel(price, qty));
        }
        return Collections.unmodifiableList(list);
    }

    public List<GridLevel> levels() { return gridLevels; }
    public PriceRange range() { return range; }
    public int count() { return levels; }
}


