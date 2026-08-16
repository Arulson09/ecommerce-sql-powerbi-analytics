SELECT 
  o.order_id,
  o.customer_id,
  o.order_status,
  CAST(o.order_purchase_timestamp AS timestamp) AS purchase_date,
  oi.product_id,
  oi.price,
  oi.freight_value,
  COALESCE(p.product_category_name, 'uncategorized') AS category,
  COALESCE(ct.product_category_name_english, 'uncategorized') AS category_english
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
LIMIT 100;