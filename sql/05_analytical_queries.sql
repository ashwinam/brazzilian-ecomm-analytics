/* 12 Business questions 
[x] What are the total numbers of orders, customers, products, and sellers?
[x] What are the monthly order-volume and sales trends?
[x] What is the average order value, using a clearly documented definition?
[x] Which ten product categories generate the most item sales?
[x] Which products have the highest item sales?
[x] Which states generate the most orders and sales?
[x] How many customers have placed more than one distinct order?
[x] What is the average time between purchases for repeat customers, where timestamps allow it to be calculated?
[x] What is the distribution of payment methods? // get the formula from gpt
[x] What percentage of delivered orders arrived later than estimated?
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

-- 6. Which states generate the most orders and sales?

/*
APPROACH

customer state belongs to customers table,
orders and sales belongs to order items,
but customer is relAted with the orders table

Join Three tables reversely
1. first bring the states and customer_ids
2. get the order ids from from orders table
3. get the prices from order items table using order_id
4. aggregate those using customer_states
*/

SELECT
    c.customer_state states,
    COUNT(o.order_id) total_orders,
    CONCAT('$ ', ROUND(SUM(oi.price), 2)) total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY customer_state;

-- 7. How many customers have placed more than one distinct order?

/*
Now i get it,
customer id belong to orders and customer unique id is the actual customers
1. first collect the customer_unique_id and customer_id
2. collect the order_id
3. count the distinct order_id based on customer unique_id, if there is no distinct then each order belongs to customer id so no need to join it, but need an distinct thats why
*/

SELECT 
    COUNT(customer_unique_id) customers_count
FROM (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT o.order_id) orders_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
)t;

-- 8. What is the average time between purchases for repeat customers, where timestamps allow it to be calculated?

/*
Question is saying that if one customer ordered 4 times
orders.          date
order 1.        january 1
order 2.        january 11
order 3.        january 21
order 4.        february 11

order 2 - order 1 = 10 days
order 3 - order 2 = 10 days
order 4 - order 3 = 20 days

10 + 10 + 20 / 3 = 13.33 is the average

APPROACH

1. collect the customer unique id
2. from orders order id and order purchase time
3. get the difference of timestamps in table
4. calculate the average
*/

SELECT 
    customer_unique_id,
    AVG(interval_days) average_interval
FROM (
    SELECT
        customer_unique_id,
        current_timestamp,
        previous_timestamp,
        ROUND(EXTRACT(EPOCH FROM(current_timestamp - previous_timestamp)) / 86400) interval_days
    FROM (
        SELECT 
            c.customer_unique_id customer_unique_id,
            o.order_purchase_timestamp current_timestamp,
            LAG(o.order_purchase_timestamp) OVER(PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) previous_timestamp
        FROM customers c
        JOIN orders o
            ON c.customer_id = o.customer_id
    )
)t
GROUP BY customer_unique_id
HAVING AVG(interval_days) IS NOT NULL;


-- 9. What is the distribution of payment methods?


SELECT 
    payment_type,
    type_count,
    CAST(type_count AS NUMERIC) / (SELECT COUNT(*) FROM order_payments) * 100 dist_percentage
FROM (
    SELECT
        payment_type,
        COUNT(payment_type) type_count
    FROM order_payments
    GROUP BY payment_type
)t;

-- 10. What percentage of delivered orders arrived later than estimated?

SELECT
    (
        CAST(COUNT(*) AS NUMERIC) / 
        (
        SELECT COUNT(*) FROM orders WHERE order_status = 'delivered'
        )
        ) * 100 
FROM orders
WHERE 
    order_status = 'delivered'
    AND order_delivered_customer_date > order_delivery_estimated_date;