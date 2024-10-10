package com.oyakov.binance_data_collection.config;

import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestClientBuilder;
import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.ElasticsearchTransport;
import co.elastic.clients.transport.rest_client.RestClientTransport;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ElasticsearchConfig {


    private final String username;
    private final String password;
    private final String host;

    public ElasticsearchConfig(
            @Value("${spring.elasticsearch.username}") String username,
            @Value("${spring.elasticsearch.password}") String password,
            @Value("${spring.elasticsearch.uris}") String[] host) {
        this.username = username;
        this.password = password;
        this.host = host[0];
    }

    @Bean
    public ElasticsearchClient elasticsearchImperativeClient() {
        // Create a credentials provider
        BasicCredentialsProvider credentialsProvider = new BasicCredentialsProvider();
        credentialsProvider.setCredentials(AuthScope.ANY, new UsernamePasswordCredentials(username, password));

        // Build the RestClient with credentials
        RestClientBuilder builder = RestClient.builder(HttpHost.create(host))
                .setHttpClientConfigCallback(httpAsyncClientBuilder -> httpAsyncClientBuilder
                        .setDefaultCredentialsProvider(credentialsProvider));

        RestClient restClient = builder.build();

        // Build the transport layer and Elasticsearch client
        ElasticsearchTransport transport = new RestClientTransport(restClient, new JacksonJsonpMapper());
        return new ElasticsearchClient(transport);
    }
}
