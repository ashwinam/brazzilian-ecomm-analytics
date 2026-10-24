-- orders table has the customer_id
ALTER TABLE orders
ADD CONSTRAINT customer_id_fk 
    FOREIGN KEY (customer_id) 
    REFERENCES customers(customer_id);

/* Creating relations for order_items table */
-- Orders Table
ALTER TABLE order_items
ADD CONSTRAINT order_id_fk
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id);

-- Products Table
ALTER TABLE order_items
ADD CONSTRAINT product_id_fk
    FOREIGN KEY (product_id)
    REFERENCES products(product_id);

-- Sellers Table
ALTER TABLE order_items
ADD CONSTRAINT seller_id_fk
    FOREIGN KEY (seller_id)
    REFERENCES sellers(seller_id);

/* Order Payments Table relations */
ALTER TABLE order_payments
ADD CONSTRAINT order_id_fk
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id);

