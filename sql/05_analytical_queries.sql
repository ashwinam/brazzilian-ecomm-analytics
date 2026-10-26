/* 12 Business questions 
[x] What are the total numbers of orders, customers, products, and sellers?
[x] What are the monthly order-volume and sales trends?
[x] What is the average order value, using a clearly documented definition?
[x] Which ten product categories generate the most item sales?
[x] Which products have the highest item sales?
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

-- 3. What is the average order value, using a clearly documented definition?
-- average order value, get the total price based on orders and calcualte the average price of it using subquery

/* Documentation
Metric: Average Order Value(orderwise)

Definition: calculate the items price, excluding the freight value

Calculation: sum the price based on order items, like each order going to have multiple items so they have prices, so i added up those and then using subquery i calculate the Average.

*/

SELECT 
    ROUND(AVG(order_price), 2)
FROM (
    SELECT 
        order_id,
        SUM(price) order_price
    FROM order_items
    GROUP BY order_id
);


-- 4. Which ten product categories generate the most item sales?

/*
1. Order has the order id (so get the order that placed by customers)
2. Then we have order items that have the product id
3. Product table has the categories, which category product/item belongs

So here don’t need an order table
Only need an order items table, join with product table, get the categories and then check which categories most ordered based on count
*/

SELECT
    p.product_category_name,
    COUNT(p.product_category_name) category_wise_ordered
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY category_wise_ordered DESC
LIMIT 10;

-- 5. Which products have the highest item sales?

/*
1. order items have the product id
2. COUNT the order_id and group by product id so get the product wise sales
3. MAX the product id so get the highest sale
*/


SELECT 
    product_id,
    SUM(price) total_sales_product_wise
FROM order_items
GROUP BY product_id
ORDER BY total_sales_product_wise DESC
LIMIT 1;