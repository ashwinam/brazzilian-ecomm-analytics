/* 12 Business questions 
1. What are the total numbers of orders, customers, products, and sellers?
2. What are the monthly order-volume and sales trends?
3. What is the average order value, using a clearly documented definition?
4. Which ten product categories generate the most item sales?
5. Which products have the highest item sales?
6. Which states generate the most orders and sales?
7. How many customers have placed more than one distinct order?
8. What is the average time between purchases for repeat customers, where timestamps allow it to be calculated?
9. What is the distribution of payment methods?
10. What percentage of delivered orders arrived later than estimated?
11. Which sellers have the highest order volume or item sales?
12. What data-quality issues exist in the source files?

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


