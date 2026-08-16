-- order sequence per real customer (customer_unique_id, not customer_id)
SELECT 
  c.customer_unique_id,
  o.order_id,
  CAST(o.order_purchase_timestamp AS timestamp) AS purchase_date,
  ROW_NUMBER() OVER (
    PARTITION BY c.customer_unique_id 
    ORDER BY CAST(o.order_purchase_timestamp AS timestamp)
  ) AS order_sequence
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY c.customer_unique_id, order_sequence
LIMIT 50;