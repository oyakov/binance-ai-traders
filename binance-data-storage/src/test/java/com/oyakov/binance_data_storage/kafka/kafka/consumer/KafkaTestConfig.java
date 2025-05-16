package com.oyakov.binance_data_storage.kafka.kafka.consumer;


import com.oyakov.binance_data_storage.repository.elastic.KlineElasticRepository;
import com.oyakov.binance_data_storage.repository.jpa.KlinePostgresRepository;
import com.oyakov.binance_data_storage.service.api.KlineDataServiceApi;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.mockito.Mockito;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;
import org.springframework.kafka.support.serializer.JsonSerializer;
import org.springframework.kafka.test.EmbeddedKafkaBroker;
import org.springframework.kafka.test.EmbeddedKafkaKraftBroker;
import org.springframework.kafka.test.context.EmbeddedKafka;

import java.util.HashMap;
import java.util.Map;

@TestConfiguration
@EmbeddedKafka(partitions = 1, topics = {"binance-kline", "binance-notification"})
public class KafkaTestConfig {

    @Bean
    public EmbeddedKafkaBroker embeddedKafkaBroker() {
        return new EmbeddedKafkaKraftBroker(1, 5, "binance-kline", "binance-notification");
    }

    @Bean
    public KlineDataServiceApi klineDataServiceApi() {
        return Mockito.mock(KlineDataServiceApi.class);
    }

    @Bean
    public KlineElasticRepository klineElasticRepository() {
        return Mockito.mock(KlineElasticRepository.class);
    }

    @Bean
    public KlinePostgresRepository klinePostgresRepository() {
        return Mockito.mock(KlinePostgresRepository.class);
    }

    @Bean
    public KafkaTemplate<String, KlineEvent> kafkaTemplate(ProducerFactory<String, KlineEvent> producerFactory) {
        return new KafkaTemplate<>(producerFactory);
    }

    @Bean
    public ProducerFactory<String, KlineEvent> producerFactory() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        configProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, KafkaAvroSerializer.class);
        return new DefaultKafkaProducerFactory<>(configProps);
    }
}