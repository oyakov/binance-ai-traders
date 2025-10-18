package com.oyakov.binance_trader_macd.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Security configuration for API endpoints
 */
@Configuration
@EnableWebSecurity
public class SecurityConfiguration {

    @Autowired
    private ApiAuthenticationFilter apiAuthenticationFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // Disable CSRF for API (stateless)
            .csrf(csrf -> csrf.disable())
            
            // Stateless session management
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            
            // Authorization rules
            .authorizeHttpRequests(auth -> auth
                // Public endpoints
                .requestMatchers("/health", "/actuator/health", "/error").permitAll()
                // All other endpoints require authentication
                .anyRequest().authenticated()
            )
            
            // Add custom API key authentication filter
            .addFilterBefore(apiAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}


