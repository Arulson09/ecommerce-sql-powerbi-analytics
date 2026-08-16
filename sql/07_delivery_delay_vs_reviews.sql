SELECT 
  r.review_score,
  ROUND(AVG(EXTRACT(DAY FROM (
    CAST(o.order_delivered_customer_date AS timestamp) - 
    CAST(o.order_estimated_delivery_date AS timestamp)
  ))), 2) AS avg_delay_days
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' 
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;