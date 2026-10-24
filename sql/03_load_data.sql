/* We will be using the COPY command
```
COPY persons(first_name, last_name, dob, email) 
FROM 'C:\Users\Raju' DELIMITER ', ' CSV HEADER;
```
*/

-- CHANGE THE LINK WITH YOUR PATH

-- Orders table

COPY orders(
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_delivery_estimated_date
    )
FROM '/Users/ashwinsmac/Developer/my_dev/projects/brazzilian-ecomm-analytics/dataset/brazilian-ecommerce/olist_orders_dataset.csv' DELIMITER ',' CSV HEADER;

-- Customers table

COPY customers(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
    )
FROM '/Users/ashwinsmac/Developer/my_dev/projects/brazzilian-ecomm-analytics/dataset/brazilian-ecommerce/olist_customers_dataset.csv' DELIMITER ',' CSV HEADER;

-- SELECT COUNT(*)
-- FROM orders;

-- Orders Payments Table
COPY order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
FROM '/Users/ashwinsmac/Developer/my_dev/projects/brazzilian-ecomm-analytics/dataset/brazilian-ecommerce/olist_order_payments_dataset.csv' DELIMITER ',' CSV HEADER;

-- Products table

COPY products (
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_quantity,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
FROM '/Users/ashwinsmac/Developer/my_dev/projects/brazzilian-ecomm-analytics/dataset/brazilian-ecommerce/olist_products_dataset.csv' DELIMITER ',' CSV HEADER;

-- Sellers table

COPY sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
FROM '/Users/ashwinsmac/Developer/my_dev/projects/brazzilian-ecomm-analytics/dataset/brazilian-ecommerce/olist_sellers_dataset.csv' DELIMITER ',' CSV HEADER;

-- Order Items Table

COPY order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
FROM '/Users/ashwinsmac/Developer/my_dev/projects/brazzilian-ecomm-analytics/dataset/brazilian-ecommerce/olist_order_items_dataset.csv' DELIMITER ',' CSV HEADER;