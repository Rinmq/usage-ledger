package com.example.usageledger.service;

import com.example.usageledger.dto.OutOfContractUsageResponse;
import com.example.usageledger.repository.IntegrityCheckRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

@Service
public class IntegrityCheckService {

    private final IntegrityCheckRepository integrityCheckRepository;

    public IntegrityCheckService(IntegrityCheckRepository integrityCheckRepository) {
        this.integrityCheckRepository = integrityCheckRepository;
    }

    public List<OutOfContractUsageResponse> findOutOfContractUsages(String month) {
        YearMonth yearMonth = YearMonth.parse(month);
        LocalDate monthStart = yearMonth.atDay(1);
        LocalDate nextMonthStart = yearMonth.plusMonths(1).atDay(1);

        return integrityCheckRepository.findOutOfContractUsages(monthStart, nextMonthStart);
    }
}