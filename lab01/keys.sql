ALTER TABLE olist.customers
    ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);

ALTER TABLE olist.orders
    ADD CONSTRAINT pk_orders PRIMARY KEY (order_id);

ALTER TABLE olist.products
    ADD CONSTRAINT pk_products PRIMARY KEY (product_id);

ALTER TABLE olist.sellers
    ADD CONSTRAINT pk_sellers PRIMARY KEY (seller_id);

ALTER TABLE olist.product_category_name_translation
    ADD CONSTRAINT pk_category_translation PRIMARY KEY (product_category_name);

ALTER TABLE olist.order_items
    ADD CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id);

ALTER TABLE olist.order_payments
    ADD CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential);

ALTER TABLE olist.order_reviews
    ADD CONSTRAINT pk_order_reviews PRIMARY KEY (review_id, order_id);

ALTER TABLE olist.orders
    ADD CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES olist.customers(customer_id);

ALTER TABLE olist.order_items
    ADD CONSTRAINT fk_items_order
    FOREIGN KEY (order_id) REFERENCES olist.orders(order_id);

ALTER TABLE olist.order_items
    ADD CONSTRAINT fk_items_product
    FOREIGN KEY (product_id) REFERENCES olist.products(product_id);

ALTER TABLE olist.order_items
    ADD CONSTRAINT fk_items_seller
    FOREIGN KEY (seller_id) REFERENCES olist.sellers(seller_id);

ALTER TABLE olist.order_payments
    ADD CONSTRAINT fk_payments_order
    FOREIGN KEY (order_id) REFERENCES olist.orders(order_id);

ALTER TABLE olist.order_reviews
    ADD CONSTRAINT fk_reviews_order
    FOREIGN KEY (order_id) REFERENCES olist.orders(order_id);
