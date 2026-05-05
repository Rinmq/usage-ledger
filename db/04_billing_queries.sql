-- 2026年4月の利用量を顧客・サービス単位で集計し、
-- 契約期間内の利用だけを請求対象として抽出する。
-- 無料枠を差し引いた従量課金額と基本料金を合算して請求金額を算出する。
WITH monthly_usage AS (
    SELECT
        u.customer_id,
        u.service_id,
        date_trunc('month', u.usage_date)::date AS billing_month,
        SUM(u.usage_amount) AS total_usage
    FROM daily_usages u
    WHERE u.usage_date >= DATE '2026-04-01'
      AND u.usage_date < DATE '2026-05-01'
    GROUP BY
        u.customer_id,
        u.service_id,
        date_trunc('month', u.usage_date)::date
),
billing_targets AS (
    SELECT
        mu.customer_id,
        c.name AS customer_name,
        mu.service_id,
        s.name AS service_name,
        mu.billing_month,
        mu.total_usage,
        p.name AS plan_name,
        p.base_price,
        p.free_usage_limit,
        p.unit_price
    FROM monthly_usage mu
    JOIN customers c
      ON c.id = mu.customer_id
    JOIN services s
      ON s.id = mu.service_id
    JOIN subscriptions sub
      ON sub.customer_id = mu.customer_id
    JOIN plans p
      ON p.id = sub.plan_id
     AND p.service_id = mu.service_id
    WHERE sub.started_on <= DATE '2026-04-30'
      AND (
          sub.ended_on IS NULL
          OR sub.ended_on >= DATE '2026-04-01'
      )
)
SELECT
    customer_id,
    customer_name,
    service_id,
    service_name,
    billing_month,
    plan_name,
    total_usage,
    free_usage_limit,
    GREATEST(total_usage - free_usage_limit, 0) AS billable_usage,
    unit_price,
    base_price,
    base_price + GREATEST(total_usage - free_usage_limit, 0) * unit_price AS amount
FROM billing_targets
ORDER BY
    customer_id,
    service_id;
