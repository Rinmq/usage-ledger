-- 契約期間外に記録された利用量を検知する。
-- daily_usages は「利用の事実」として保持し、
-- 請求時または監査時に subscriptions / plans と突き合わせる。
--
-- このSQLでは、利用日 usage_date に有効な契約が存在しない利用量を抽出する。

SELECT
    u.id AS daily_usage_id,
    c.id AS customer_id,
    c.name AS customer_name,
    s.id AS service_id,
    s.name AS service_name,
    u.usage_date,
    u.usage_amount
FROM daily_usages u
JOIN customers c
  ON c.id = u.customer_id
JOIN services s
  ON s.id = u.service_id
WHERE NOT EXISTS (
    SELECT 1
    FROM subscriptions sub
    JOIN plans p
      ON p.id = sub.plan_id
    WHERE sub.customer_id = u.customer_id
      AND p.service_id = u.service_id
      AND sub.started_on <= u.usage_date
      AND (
          sub.ended_on IS NULL
          OR sub.ended_on >= u.usage_date
      )
)
ORDER BY
    u.customer_id,
    u.service_id,
    u.usage_date;