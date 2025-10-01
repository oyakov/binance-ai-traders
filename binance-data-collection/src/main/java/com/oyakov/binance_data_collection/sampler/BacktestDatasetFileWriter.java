package com.oyakov.binance_data_collection.sampler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.regex.Pattern;

@Component
@Log4j2
@RequiredArgsConstructor
public class BacktestDatasetFileWriter {

    private static final DateTimeFormatter FILE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyyMMddHHmmss").withZone(ZoneOffset.UTC);
    private static final Pattern SAFE_FILENAME_PATTERN = Pattern.compile("[^a-z0-9_-]+");
    private final ObjectMapper objectMapper;

    public Path writeDataset(BacktestDataset dataset, String outputDirectory) {
        try {
            Path directory = Path.of(outputDirectory);
            Files.createDirectories(directory);
            String timestamp = FILE_TIME_FORMATTER.format(dataset.getCollectedAt());
            String datasetLabel = buildDatasetLabel(dataset);
            String fileName = "%s_%s.json".formatted(datasetLabel, timestamp);
            Path file = directory.resolve(fileName);
            objectMapper.writerWithDefaultPrettyPrinter().writeValue(file.toFile(), dataset);
            log.info("Saved dataset {} with {} klines to {}", dataset.getName(), dataset.getKlines().size(), file);
            return file;
        } catch (IOException e) {
            throw new IllegalStateException("Failed to write dataset " + dataset.getName(), e);
        }
    }

    private String buildDatasetLabel(BacktestDataset dataset) {
        String baseName = dataset.getName() != null && !dataset.getName().isBlank()
                ? dataset.getName()
                : "%s_%s".formatted(dataset.getSymbol(), dataset.getInterval());
        String lower = baseName.toLowerCase(Locale.ROOT).replace(' ', '-');
        return SAFE_FILENAME_PATTERN.matcher(lower).replaceAll("-");
    }
}
