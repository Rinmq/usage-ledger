package com.example.usageledger.dto;

import java.time.LocalDate;

public record OutOfContractUsageResponse(
        Long dailyUsageId,
        Long customerId,
        String customerName,
        Long serviceId,
        String serviceName,
        LocalDate usageDate,
        Long usageAmount
) {
}