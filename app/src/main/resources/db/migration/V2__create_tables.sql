CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_customers_status
        CHECK (status IN ('active', 'inactive'))
);

CREATE TABLE services (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE plans (
    id BIGSERIAL PRIMARY KEY,
    service_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    base_price NUMERIC(10, 2) NOT NULL DEFAULT 0,
    free_usage_limit INTEGER NOT NULL DEFAULT 0,
    unit_price NUMERIC(10, 4) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_plans_service
        FOREIGN KEY (service_id)
        REFERENCES services(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_plans_base_price
        CHECK (base_price >= 0),

    CONSTRAINT chk_plans_free_usage_limit
        CHECK (free_usage_limit >= 0),

    CONSTRAINT chk_plans_unit_price
        CHECK (unit_price >= 0),

    CONSTRAINT uq_plans_service_name
        UNIQUE (service_id, name)
);

CREATE TABLE subscriptions (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    plan_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    started_on DATE NOT NULL,
    ended_on DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_subscriptions_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_subscriptions_plan
        FOREIGN KEY (plan_id)
        REFERENCES plans(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_subscriptions_status
        CHECK (status IN ('active', 'canceled', 'suspended')),

    CONSTRAINT chk_subscriptions_period
        CHECK (ended_on IS NULL OR ended_on >= started_on)
);

CREATE TABLE daily_usages (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    usage_date DATE NOT NULL,
    usage_amount INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_daily_usages_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_daily_usages_service
        FOREIGN KEY (service_id)
        REFERENCES services(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_daily_usages_usage_amount
        CHECK (usage_amount >= 0),

    CONSTRAINT uq_daily_usages_customer_service_date
        UNIQUE (customer_id, service_id, usage_date)
);

CREATE TABLE invoices (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    billing_month DATE NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    issued_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_invoices_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_invoices_total_amount
        CHECK (total_amount >= 0),

    CONSTRAINT chk_invoices_status
        CHECK (status IN ('draft', 'issued', 'paid', 'void')),

    CONSTRAINT uq_invoices_customer_billing_month
        UNIQUE (customer_id, billing_month)
);

CREATE TABLE invoice_items (
    id BIGSERIAL PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    usage_amount INTEGER NOT NULL DEFAULT 0,
    free_usage_amount INTEGER NOT NULL DEFAULT 0,
    billable_usage_amount INTEGER NOT NULL DEFAULT 0,
    unit_price NUMERIC(10, 4) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_invoice_items_invoice
        FOREIGN KEY (invoice_id)
        REFERENCES invoices(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_invoice_items_service
        FOREIGN KEY (service_id)
        REFERENCES services(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_invoice_items_usage_amount
        CHECK (usage_amount >= 0),

    CONSTRAINT chk_invoice_items_free_usage_amount
        CHECK (free_usage_amount >= 0),

    CONSTRAINT chk_invoice_items_billable_usage_amount
        CHECK (billable_usage_amount >= 0),

    CONSTRAINT chk_invoice_items_unit_price
        CHECK (unit_price >= 0),

    CONSTRAINT chk_invoice_items_amount
        CHECK (amount >= 0)
);

CREATE INDEX idx_subscriptions_customer_plan_period
    ON subscriptions (customer_id, plan_id, started_on, ended_on);

CREATE INDEX idx_daily_usages_customer_service_date
    ON daily_usages (customer_id, service_id, usage_date);

CREATE INDEX idx_daily_usages_usage_date
    ON daily_usages (usage_date);

CREATE INDEX idx_invoices_billing_month
    ON invoices (billing_month);

CREATE INDEX idx_invoice_items_invoice_id
    ON invoice_items (invoice_id);
    