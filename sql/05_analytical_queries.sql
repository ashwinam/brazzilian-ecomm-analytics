/* 12 Business questions 
[x] What are the total numbers of orders, customers, products, and sellers?
[x] What are the monthly order-volume and sales trends?
[] What is the average order value, using a clearly documented definition?
[] Which ten product categories generate the most item sales?
[] Which products have the highest item sales?
[] Which states generate the most orders and sales?
[] How many customers have placed more than one distinct order?
[] What is the average time between purchases for repeat customers, where timestamps allow it to be calculated?
[] What is the distribution of payment methods?
[] What percentage of delivered orders arrived later than estimated?
[] Which sellers have the highest order volume or item sales?
[] What data-quality issues exist in the source files?

*/

-- 1. What are the total number of orders, customers, products and sellers?

-- Total number of orders
SELECT COUNT(*)
FROM orders;

-- Total number of customers
SELECT COUNT(*)
FROM customers;

-- Total number of products
SELECT COUNT(*)
FROM products

-- Total number of Sellers
SELECT COUNT(*)
FROM sellers;

-- 2. What are the monthly order-volume and sales trends?

-- Collect the monthwise order-volume using purchase date column

-- Create Temporary table for same session usage, dont want the headache to drop the table afterwards
CREATE TEMPORARY TABLE monthwise_orders_and_total_sales AS
    SELECT 
        TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') period,
        COUNT(oi.order_id) total_orders_monthwise,
        SUM(oi.price) total_sales_monthwise
    FROM orders o
    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY period
    ORDER BY period DESC;


-- Query for order-volume
SELECT 
    period,
    total_orders_monthwise
FROM monthwise_orders_and_total_sales;

-- Querying for sales trends
WITH sales_summary AS(

    SELECT 
        period,
        total_orders_monthwise,
        total_sales_monthwise current_month_sales,
        LAG(total_sales_monthwise) OVER(ORDER BY period ASC) previous_month_sales
    FROM monthwise_orders_and_total_sales
)
SELECT
    period,
    total_orders_monthwise,
    current_month_sales,
    previous_month_sales,
    CONCAT(ROUND(((current_month_sales - previous_month_sales) / previous_month_sales) * 100, 2), '%')
FROM sales_summary;

-- NOTE: here missing thing is to month wise sequence is not complete, for sales trends needs to be every month if any month missing then add 0 or null but for complexity i avoided those addons

