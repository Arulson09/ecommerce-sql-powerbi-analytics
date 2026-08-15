-- customers - checked nulls, duplicates, state values
-- all clean
SELECT COUNT(*) FROM customers;

SELECT 
  COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
  COUNT(*) FILTER (WHERE customer_unique_id IS NULL) AS null_unique_id,
  COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL) AS null_zip,
  COUNT(*) FILTER (WHERE customer_city IS NULL) AS null_city,
  COUNT(*) FILTER (WHERE customer_state IS NULL) AS null_state
FROM customers;

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT DISTINCT customer_state FROM customers ORDER BY customer_state;


-- sellers - checked nulls, duplicates, state values
-- clean. only 23 states not 27, makes sense - not every state has sellers
SELECT COUNT(*) FROM sellers;

SELECT 
  COUNT(*) FILTER (WHERE seller_id IS NULL) AS null_seller_id,
  COUNT(*) FILTER (WHERE seller_zip_code_prefix IS NULL) AS null_zip,
  COUNT(*) FILTER (WHERE seller_city IS NULL) AS null_city,
  COUNT(*) FILTER (WHERE seller_state IS NULL) AS null_state
FROM sellers;

SELECT seller_id, COUNT(*)
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT DISTINCT seller_state FROM sellers ORDER BY seller_state;


-- products - checked nulls, duplicates, bad values
-- 610 rows with no category, leaving as null, using coalesce later
-- 2 products missing all dimensions, 4 with weight = 0 - small, not using these fields anyway
SELECT COUNT(*) FROM products;

SELECT 
  COUNT(*) FILTER (WHERE product_id IS NULL) AS null_id,
  COUNT(*) FILTER (WHERE product_category_name IS NULL) AS null_category,
  COUNT(*) FILTER (WHERE product_weight_g IS NULL) AS null_weight,
  COUNT(*) FILTER (WHERE product_length_cm IS NULL) AS null_length,
  COUNT(*) FILTER (WHERE product_height_cm IS NULL) AS null_height,
  COUNT(*) FILTER (WHERE product_width_cm IS NULL) AS null_width
FROM products;

SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT COUNT(*) 
FROM products
WHERE product_weight_g <= 0 
   OR product_length_cm <= 0 
   OR product_height_cm <= 0 
   OR product_width_cm <= 0;

-- checking category fk is clean after fixes in 02_fk_fixes.sql, should be 0
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN category_translation ct 
  ON p.product_category_name = ct.product_category_name
WHERE ct.product_category_name IS NULL 
  AND p.product_category_name IS NOT NULL;


-- orders - checked nulls, duplicates, status breakdown
-- nulls in approved_at/carrier_date/delivered_date line up with non-delivered orders
-- checked status counts, makes sense, not a data problem
SELECT COUNT(*) FROM orders;

SELECT 
  COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
  COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
  COUNT(*) FILTER (WHERE order_status IS NULL) AS null_status,
  COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS null_purchase_ts,
  COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS null_approved_at,
  COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL) AS null_carrier_date,
  COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS null_delivered_date,
  COUNT(*) FILTER (WHERE order_estimated_delivery_date IS NULL) AS null_estimated_date
FROM orders;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_status, COUNT(*) 
FROM orders
GROUP BY order_status
ORDER BY COUNT(*) DESC;

SELECT COUNT(*) 
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- order_items - checked nulls, duplicates, price/freight, orphaned keys
-- all clean
SELECT COUNT(*) FROM order_items;

SELECT 
  COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
  COUNT(*) FILTER (WHERE order_item_id IS NULL) AS null_item_id,
  COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
  COUNT(*) FILTER (WHERE seller_id IS NULL) AS null_seller_id,
  COUNT(*) FILTER (WHERE price IS NULL) AS null_price,
  COUNT(*) FILTER (WHERE freight_value IS NULL) AS null_freight
FROM order_items;

SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT COUNT(*) 
FROM order_items
WHERE price <= 0 OR freight_value < 0;

SELECT 
  (SELECT COUNT(*) FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id WHERE o.order_id IS NULL) AS orphaned_orders,
  (SELECT COUNT(*) FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id WHERE p.product_id IS NULL) AS orphaned_products,
  (SELECT COUNT(*) FROM order_items oi LEFT JOIN sellers s ON oi.seller_id = s.seller_id WHERE s.seller_id IS NULL) AS orphaned_sellers;


-- payments - checked nulls, duplicates, payment types, bad values, orphaned keys
-- all clean
SELECT COUNT(*) FROM payments;

SELECT 
  COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
  COUNT(*) FILTER (WHERE payment_sequential IS NULL) AS null_seq,
  COUNT(*) FILTER (WHERE payment_type IS NULL) AS null_type,
  COUNT(*) FILTER (WHERE payment_installments IS NULL) AS null_installments,
  COUNT(*) FILTER (WHERE payment_value IS NULL) AS null_value
FROM payments;

SELECT order_id, payment_sequential, COUNT(*)
FROM payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

SELECT payment_type, COUNT(*) 
FROM payments
GROUP BY payment_type
ORDER BY COUNT(*) DESC;

SELECT COUNT(*) 
FROM payments
WHERE payment_value <= 0;

SELECT COUNT(*) 
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- reviews - checking score range and nulls
SELECT 
  COUNT(*) FILTER (WHERE review_score IS NULL) AS null_score,
  COUNT(*) FILTER (WHERE review_score < 1 OR review_score > 5) AS out_of_range_score,
  COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id
FROM reviews;


-- geolocation - not used in this project, skipping deep checks