
/* 
This script is for the data quality checks, is the data relaible or not

Following checks i am going to do:
[x] Duplicate primary-key values.
[] Missing or blank values in important columns.
[] Invalid or orphaned foreign-key references.
[] Orders without matching order items, where unexpected.
[] Order timestamps that appear inconsistent or occur in an unexpected sequence.
[] Negative or implausible monetary values, investigated in context rather than automatically deleted.
[] Unexpected order statuses.
[] Payment totals that differ from item and freight totals, treated as an investigation rather than automatically assumed to be an error.
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

