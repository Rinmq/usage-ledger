INSERT INTO services (code, name) VALUES
    ('message_api', 'Message API'),
    ('image_api', 'Image API'),
    ('analytics_api', 'Analytics API');

INSERT INTO plans (service_id, name, base_price, free_usage_limit, unit_price) VALUES
    (
        (SELECT id FROM services WHERE code = 'message_api'),
        'Standard',
        3000,
        10000,
        0.2000
    ),
    (
        (SELECT id FROM services WHERE code = 'message_api'),
        'Business',
        10000,
        50000,
        0.1500
    ),
    (
        (SELECT id FROM services WHERE code = 'image_api'),
        'Standard',
        5000,
        1000,
        2.5000
    ),
    (
        (SELECT id FROM services WHERE code = 'analytics_api'),
        'Standard',
        8000,
        5000,
        1.2000
    );

INSERT INTO customers (name, email, status) VALUES
    ('Alpha Corporation', 'billing-alpha@example.com', 'active'),
    ('Beta Works', 'billing-beta@example.com', 'active'),
    ('Gamma Studio', 'billing-gamma@example.com', 'inactive');
    