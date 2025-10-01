package com.oyakov.binance_shared_model.kafka.deserializer;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.apache.avro.io.BinaryDecoder;
import org.apache.avro.io.DatumReader;
import org.apache.avro.io.DecoderFactory;
import org.apache.avro.specific.SpecificDatumReader;
import org.apache.kafka.common.serialization.Deserializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Map;

/**
 * Kafka deserializer for CommandMarker (KlineEvent) objects.
 * This deserializer converts byte arrays back to KlineEvent objects using Avro.
 */
public class CommandMarkerDeserializer implements Deserializer<KlineEvent> {
    
    private static final Logger logger = LoggerFactory.getLogger(CommandMarkerDeserializer.class);
    
    private DatumReader<KlineEvent> datumReader;
    
    @Override
    public void configure(Map<String, ?> configs, boolean isKey) {
        // Initialize the Avro datum reader for KlineEvent
        this.datumReader = new SpecificDatumReader<>(KlineEvent.class);
        logger.debug("CommandMarkerDeserializer configured for KlineEvent deserialization");
    }
    
    @Override
    public KlineEvent deserialize(String topic, byte[] data) {
        if (data == null) {
            logger.debug("Received null data for topic: {}", topic);
            return null;
        }
        
        try {
            // Create a binary decoder for the byte array
            BinaryDecoder decoder = DecoderFactory.get().binaryDecoder(data, null);
            
            // Deserialize the data to KlineEvent
            KlineEvent klineEvent = datumReader.read(null, decoder);
            
            logger.debug("Successfully deserialized KlineEvent for topic: {}, symbol: {}", 
                        topic, klineEvent.getSymbol());
            
            return klineEvent;
            
        } catch (IOException e) {
            logger.error("Failed to deserialize KlineEvent for topic: {}", topic, e);
            throw new RuntimeException("Failed to deserialize KlineEvent", e);
        } catch (Exception e) {
            logger.error("Unexpected error during deserialization for topic: {}", topic, e);
            throw new RuntimeException("Unexpected error during deserialization", e);
        }
    }
    
    @Override
    public void close() {
        // Clean up resources if needed
        logger.debug("CommandMarkerDeserializer closed");
    }
}
