package com.oyakov.binance_shared_model.kafka.serializer;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import org.apache.avro.io.BinaryEncoder;
import org.apache.avro.io.DatumWriter;
import org.apache.avro.io.EncoderFactory;
import org.apache.avro.specific.SpecificDatumWriter;
import org.apache.kafka.common.serialization.Serializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Map;

/**
 * Kafka serializer for CommandMarker (KlineEvent) objects.
 * This serializer converts KlineEvent objects to byte arrays using Avro.
 */
public class CommandMarkerSerializer implements Serializer<KlineEvent> {
    
    private static final Logger logger = LoggerFactory.getLogger(CommandMarkerSerializer.class);
    
    private DatumWriter<KlineEvent> datumWriter;
    
    @Override
    public void configure(Map<String, ?> configs, boolean isKey) {
        // Initialize the Avro datum writer for KlineEvent
        this.datumWriter = new SpecificDatumWriter<>(KlineEvent.class);
        logger.debug("CommandMarkerSerializer configured for KlineEvent serialization");
    }
    
    @Override
    public byte[] serialize(String topic, KlineEvent data) {
        if (data == null) {
            logger.debug("Received null data for topic: {}", topic);
            return null;
        }
        
        try {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BinaryEncoder encoder = EncoderFactory.get().binaryEncoder(outputStream, null);
            
            // Serialize the KlineEvent to bytes
            datumWriter.write(data, encoder);
            encoder.flush();
            
            byte[] serializedData = outputStream.toByteArray();
            
            logger.debug("Successfully serialized KlineEvent for topic: {}, symbol: {}, size: {} bytes", 
                        topic, data.getSymbol(), serializedData.length);
            
            return serializedData;
            
        } catch (IOException e) {
            logger.error("Failed to serialize KlineEvent for topic: {}", topic, e);
            throw new RuntimeException("Failed to serialize KlineEvent", e);
        } catch (Exception e) {
            logger.error("Unexpected error during serialization for topic: {}", topic, e);
            throw new RuntimeException("Unexpected error during serialization", e);
        }
    }
    
    @Override
    public void close() {
        // Clean up resources if needed
        logger.debug("CommandMarkerSerializer closed");
    }
}
