INSERT INTO subscriptions (customer_id, plan_id, status, started_on, ended_on) VALUES
    (
        (SELECT id FROM customers WHERE email = 'billing-alpha@example.com'),
        (SELECT p.id FROM plans p JOIN services s ON s.id = p.service_id WHERE s.code = 'message_api' AND p.name = 'Standard'),
        'active',
        DATE '2026-04-01',
        NULL
    ),
    (
        (SELECT id FROM customers WHERE email = 'billing-alpha@example.com'),
        (SELECT p.id FROM plans p JOIN services s ON s.id = p.service_id WHERE s.code = 'image_api' AND p.name = 'Standard'),
        'active',
        DATE '2026-04-10',
        NULL
    ),
    (
        (SELECT id FROM customers WHERE email = 'billing-beta@example.com'),
        (SELECT p.id FROM plans p JOIN services s ON s.id = p.service_id WHERE s.code = 'message_api' AND p.name = 'Business'),
        'active',
        DATE '2026-03-15',
        NULL
    ),
    (
        (SELECT id FROM customers WHERE email = 'billing-gamma@example.com'),
        (SELECT p.id FROM plans p JOIN services s ON s.id = p.service_id WHERE s.code = 'analytics_api' AND p.name = 'Standard'),
        'canceled',
        DATE '2026-03-01',
        DATE '2026-03-31'
    );

INSERT INTO daily_usages (customer_id, service_id, usage_date, usage_amount) VALUES
    (
        (SELECT id FROM customers WHERE email = 'billing-alpha@example.com'),
        (SELECT id FROM services WHERE code = 'message_api'),
        DATE '2026-04-01',
        1200
    ),
    (
        (SELECT id FROM customers WHERE email = 'billing-alpha@example.com'),
        (SELECT id FROM services WHERE code = 'message_api'),
        DATE '2026-04-02',
        1500
    ),
    (
        (SELECT id FROM customers WHERE email = 'billing-alpha@example.com'),
        (SELECT id FROM services WHERE code = 'message_api'),
        DATE '2026-04-03',
        9000
    ),
    (
        (SELECT id FROM customers WHERE email = 'billing-alpha@example.com'),
        (SELECT id FROM services WHERE code = 'image_api'),
        DATE '2026-04-15',
        300
    ),
    (
        (SELECT id FROM customers WHERE email = 'billing-alpha@example.com'),
        (SELECT id FROM services WHERE code = 'image_api'),
        DATE '2026-04-16',
        900
    ),
    (
        (SELECT id FROM customers WHERE email = 'billing-beta@example.com'),
        (SELECT id FROM services WHERE code = 'message_api'),
        DATE '2026-04-01',
        30000
    ),
    (
        (SELECT id FROM customers WHERE email = 'billing-beta@example.com'),
        (SELECT id FROM services WHERE code = 'message_api'),
        DATE '2026-04-02',
        35000
    ),
    (
        (SELECT id FROM customers WHERE email = 'billing-gamma@example.com'),
        (SELECT id FROM services WHERE code = 'analytics_api'),
        DATE '2026-04-05',
        2000
    );
