package com.oyakov.binance_trader_grid.grid;

/**
 * Represents one discrete price level in a grid with its target quantity.
 */
public final class GridLevel {
    private final double price;
    private final double quantity; // base asset amount to buy/sell at this level

    public GridLevel(double price, double quantity) {
        if (price <= 0 || quantity < 0) {
            throw new IllegalArgumentException("price>0 and quantity>=0 required");
        }
        this.price = price;
        this.quantity = quantity;
    }

    public double price() { return price; }
    public double quantity() { return quantity; }
}


