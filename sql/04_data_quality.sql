
/* 
This script is for the data quality checks, is the data relaible or not

Following checks i am going to do:
[x] Duplicate primary-key values.
[x] Missing or blank values in important columns.
[x] Invalid or orphaned foreign-key references.
[x] Orders without matching order items, where unexpected.
[x] Payment totals that differ from item and freight totals, treated as an investigation rather than automatically assumed to be an error.
[x] CSV row counts compared with PostgreSQL row counts after loading.
*/

-- Count of all the tables

SELECT COUNT(*) order_counts
FROM orders
UNION ALL
SELECT COUNT(*) customer_counts
FROM customers
UNION ALL
SELECT COUNT(*) order_items_count
FROM order_items
UNION ALL
SELECT COUNT(*) order_payments_count
FROM order_payments
UNION ALL
SELECT COUNT(*) products_count
FROM products
UNION ALL
SELECT COUNT(*) sellers_count
FROM sellers;

-- Duplicate Primary Key Values
-- ORDERS TABLE

SELECT COUNT(*) orders_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Customers Table

SELECT COUNT(*) customers_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- order_items Table

SELECT COUNT(*) orders_items_count
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- products Table

SELECT COUNT(*) products_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Sellers Table

SELECT COUNT(*) sellers_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- Order Payments 

SELECT COUNT(*) order_payments_count
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- Missing or blank values in important columns.

-- orders table

SELECT *
FROM orders
WHERE customer_id IS NULL;

-- customers table
SELECT *
FROM customers
WHERE 
    customer_unique_id IS NULL OR 
    customer_city IS NULL OR 
    customer_state IS NULL;

-- order items table
SELECT *
FROM order_items
WHERE 
    product_id IS NULL OR
    seller_id IS NULL OR
    price IS NULL OR
    freight_value IS NULL;

-- Order Payments Table
SELECT *
FROM order_payments
WHERE 
    payment_type IS NULL OR
    payment_installments IS NULL OR
    payment_value IS NULL;

-- Invalid or orphaned foreign-key references.

-- Check the null values using joins in orders and customers table

SELECT  
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
USING(customer_id)
WHERE c.customer_id IS NULL;

-- Orders without matching order items, where unexpected.

-- Checking unmatched records with orders and order items

SELECT 
    oi.order_id,
    oi.order_item_id
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Payment totals that differ from item and freight totals, treated as an investigation rather than automatically assumed to be an error. (order_items -> price + freigh_value == order_payments -> payment_value)

WITH order_item_summary AS (
--  this will return the order items table sum and total of order value
SELECT 
    order_id,
    SUM(price) total_price_orderwise,
    SUM(freight_value) total_freight_orderwise,
    (SUM(price) + SUM(freight_value)) total_amount_orderwise,
    COUNT(*) total_count_orderwise
FROM order_items
GROUP BY order_id
-- ORDER BY total_count_orderwise DESC
),
order_payment_summary AS (
    -- This will give the total payment paid against the order
    SELECT 
        order_id,
        SUM(payment_value) total_payment_paid_orderwise
    FROM order_payments
    GROUP BY order_id
),
-- total_order_payment_installments AS (
-- Just for extra checks for discrepency
--     SELECT 
--         order_id,
--         SUM(payment_installments) total_payment_installments_orderwise
--     FROM order_payments
--     GROUP BY order_id
-- )

-- Main Query
SELECT 
    oi.order_id order_items_orders,
    op.order_id order_payments_orders,
    oi.total_amount_orderwise,
    op.total_payment_paid_orderwise,
    -- opi.total_payment_installments_orderwise,
    (oi.total_amount_orderwise - op.total_payment_paid_orderwise) difference
FROM order_item_summary oi
LEFT JOIN order_payment_summary op
    ON oi.order_id = op.order_id
-- LEFT JOIN total_order_payment_installments opi
--     ON op.order_id = opi.order_id
WHERE (oi.total_amount_orderwise - op.total_payment_paid_orderwise) != 0
ORDER BY ABS((oi.total_amount_orderwise - op.total_payment_paid_orderwise)) DESC;

-- FOUND 576 DISCREPENCIES