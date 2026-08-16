WITH order_counts AS (
  SELECT c.customer_unique_id, COUNT(o.order_id) AS total_orders
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
)
SELECT 
  CASE WHEN total_orders = 1 THEN 'One-time buyer' ELSE 'Repeat buyer' END AS customer_type,
  COUNT(*) AS num_customers,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers
FROM order_counts
GROUP BY CASE WHEN total_orders = 1 THEN 'One-time buyer' ELSE 'Repeat buyer' END;