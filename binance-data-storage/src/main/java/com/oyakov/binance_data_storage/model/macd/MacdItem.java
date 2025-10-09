package com.oyakov.binance_data_storage.model.macd;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "macd")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MacdItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String symbol;

    @Column(name = "interval")
    private String interval;

    @Column(name = "timestamp")
    private long timestamp;

    private LocalDateTime collection_time;
    private LocalDateTime display_time;

    private Double ema_fast;
    private Double ema_slow;
    private Double macd;
    private Double signal;
    private Double histogram;

    private Double signal_buy;
    private Double signal_sell;
    private Double volume_signal;
    private Double buy;
    private Double sell;
}


