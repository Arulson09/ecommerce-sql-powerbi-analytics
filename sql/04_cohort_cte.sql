-- first purchase date per real customer (customer_unique_id, not customer_id)
WITH first_purchase AS (
  SELECT 
    c.customer_unique_id,
    MIN(CAST(o.order_purchase_timestamp AS timestamp)) AS first_purchase_date
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
)
SELECT 
  fp.customer_unique_id,
  fp.first_purchase_date,
  DATE_TRUNC('month', fp.first_purchase_date) AS cohort_month
FROM first_purchase fp
ORDER BY fp.first_purchase_date
LIMIT 50;