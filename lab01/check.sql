SELECT 'customers' AS table_name, count(*) FROM olist.customers
UNION ALL SELECT 'geolocation', count(*) FROM olist.geolocation
UNION ALL SELECT 'orders', count(*) FROM olist.orders
UNION ALL SELECT 'order_items', count(*) FROM olist.order_items
UNION ALL SELECT 'order_payments', count(*) FROM olist.order_payments
UNION ALL SELECT 'order_reviews', count(*) FROM olist.order_reviews
UNION ALL SELECT 'products', count(*) FROM olist.products
UNION ALL SELECT 'sellers', count(*) FROM olist.sellers
UNION ALL SELECT 'product_category_name_translation', count(*) FROM olist.product_category_name_translation
ORDER BY table_name;

SELECT 'orphan order_items->orders' AS check_name, count(*) AS cnt
FROM olist.order_items oi
LEFT JOIN olist.orders o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'orphan orders->customers', count(*)
FROM olist.orders o
LEFT JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'orphan order_items->products', count(*)
FROM olist.order_items oi
LEFT JOIN olist.products p ON p.product_id = oi.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'orphan order_items->sellers', count(*)
FROM olist.order_items oi
LEFT JOIN olist.sellers s ON s.seller_id = oi.seller_id
WHERE s.seller_id IS NULL
UNION ALL
SELECT 'orphan order_payments->orders', count(*)
FROM olist.order_payments op
LEFT JOIN olist.orders o ON o.order_id = op.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'orphan order_reviews->orders', count(*)
FROM olist.order_reviews r
LEFT JOIN olist.orders o ON o.order_id = r.order_id
WHERE o.order_id IS NULL;

ANALYZE olist.customers;
ANALYZE olist.geolocation;
ANALYZE olist.orders;
ANALYZE olist.order_items;
ANALYZE olist.order_payments;
ANALYZE olist.order_reviews;
ANALYZE olist.products;
ANALYZE olist.sellers;
ANALYZE olist.product_category_name_translation;
