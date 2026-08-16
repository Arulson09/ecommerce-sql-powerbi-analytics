SELECT 
  COALESCE(ct.product_category_name_english, 'uncategorized') AS category,
  COUNT(DISTINCT oi.order_id) AS num_orders,
  ROUND(CAST(SUM(oi.price) AS numeric), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
GROUP BY COALESCE(ct.product_category_name_english, 'uncategorized')
ORDER BY total_revenue DESC
LIMIT 15;