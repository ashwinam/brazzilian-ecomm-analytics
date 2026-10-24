-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    order_id UUID PRIMARY KEY,
    customer_id UUID,
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_delivery_estimated_date TIMESTAMP
);

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    order_id UUID NOT NULL,
    order_item_id INTEGER,
    product_id UUID,
    seller_id UUID,
    shipping_limit_date TIMESTAMP,
    price numeric,
    freight_value numeric,
    PRIMARY KEY (order_id, order_item_id)
);

-- Order Payments Table
CREATE TABLE IF NOT EXISTS order_payments (
    order_id UUID NOT NULL,
    payment_sequential INTEGER,
    payment_type VARCHAR(50),
    payment_installments INTEGER,
    payment_value NUMERIC,
    PRIMARY KEY(order_id, payment_sequential)
);

-- Customers Table
CREATE TABLE IF NOT EXISTS customers(
    customer_id UUID PRIMARY KEY,
    customer_unique_id UUID NOT NULL,
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(50),
    customer_state CHAR(3)
);

-- Products Table
CREATE TABLE IF NOT EXISTS products(
    product_id UUID PRIMARY KEY,
    product_category_name VARCHAR(255),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_quantity INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- Sellers Table
CREATE TABLE IF NOT EXISTS sellers (
    seller_id UUID PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(255),
    seller_state CHAR(3)
);