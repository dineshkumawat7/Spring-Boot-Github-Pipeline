package com.example.pipeline.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1")
public class MainController {

    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> status(){
        Map<String, Object> status = new LinkedHashMap<>();
        status.put("status", "Running");
        log.info("Returning response for status: {}", status);
        return ResponseEntity.status(HttpStatus.OK).body(status);
    }
}
