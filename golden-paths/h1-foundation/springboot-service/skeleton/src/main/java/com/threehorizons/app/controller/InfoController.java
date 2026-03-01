package com.threehorizons.app.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class InfoController {

    @Value("${spring.application.name:unknown}")
    private String name;

    @Value("${app.version:1.0.0}")
    private String version;

    @Value("${app.environment:development}")
    private String environment;

    @GetMapping("/info")
    public Map<String, String> getInfo() {
        return Map.of(
            "name", name,
            "version", version,
            "environment", environment
        );
    }
}
