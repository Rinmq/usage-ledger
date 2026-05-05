package com.example.usageledger.controller;

import com.example.usageledger.dto.OutOfContractUsageResponse;
import com.example.usageledger.service.IntegrityCheckService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class IntegrityCheckController {

    private final IntegrityCheckService integrityCheckService;

    public IntegrityCheckController(IntegrityCheckService integrityCheckService) {
        this.integrityCheckService = integrityCheckService;
    }

    @GetMapping("/integrity-checks/out-of-contract-usages")
    public List<OutOfContractUsageResponse> findOutOfContractUsages(@RequestParam String month) {
        return integrityCheckService.findOutOfContractUsages(month);
    }
}
