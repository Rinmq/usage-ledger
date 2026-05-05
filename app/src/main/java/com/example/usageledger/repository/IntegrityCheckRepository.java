package com.example.usageledger.repository;

import com.example.usageledger.dto.OutOfContractUsageResponse;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public class IntegrityCheckRepository {

    private final JdbcClient jdbcClient;

    public IntegrityCheckRepository(JdbcClient jdbcClient) {
        this.jdbcClient = jdbcClient;
    }

    public List<OutOfContractUsageResponse> findOutOfContractUsages(LocalDate monthStart, LocalDate nextMonthStart) {
        String sql = """
                SELECT
                    du.id AS daily_usage_id,
                    c.id AS customer_id,
                    c.name AS customer_name,
                    s.id AS service_id,
                    s.name AS service_name,
                    du.usage_date,
                    du.usage_amount
                FROM daily_usages du
                JOIN customers c
                  ON c.id = du.customer_id
                JOIN services s
                  ON s.id = du.service_id
                WHERE du.usage_date >= :monthStart
                  AND du.usage_date < :nextMonthStart
                  AND NOT EXISTS (
                      SELECT 1
                      FROM subscriptions sub
                      JOIN plans p
                        ON p.id = sub.plan_id
                       AND p.service_id = du.service_id
                      WHERE sub.customer_id = du.customer_id
                        AND sub.started_on <= du.usage_date
                        AND (
                            sub.ended_on IS NULL
                            OR sub.ended_on >= du.usage_date
                        )
                  )
                ORDER BY
                    du.usage_date,
                    c.id,
                    s.id
                """;

        return jdbcClient.sql(sql)
                .param("monthStart", monthStart)
                .param("nextMonthStart", nextMonthStart)
                .query((rs, rowNum) -> new OutOfContractUsageResponse(
                        rs.getLong("daily_usage_id"),
                        rs.getLong("customer_id"),
                        rs.getString("customer_name"),
                        rs.getLong("service_id"),
                        rs.getString("service_name"),
                        rs.getObject("usage_date", LocalDate.class),
                        rs.getLong("usage_amount")
                ))
                .list();
    }
}
