-- products.product_category_name had 2 values missing from category_translation
-- found these using a left join + null check
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN category_translation ct 
  ON p.product_category_name = ct.product_category_name
WHERE ct.product_category_name IS NULL;
-- returned: pc_gamer, portateis_cozinha_e_preparadores_de_alimentos

-- fix 1
INSERT INTO category_translation (product_category_name, product_category_name_english)
VALUES ('pc_gamer', 'pc_gamer');

-- fix 2
INSERT INTO category_translation (product_category_name, product_category_name_english)
VALUES ('portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_portables_and_food_preparers');

-- after these inserts, added the fk on products -> category_translation, went through fine

-- note: 610 products still have null category - that's fine, fk allows nulls
-- these are products with no category assigned, not a translation gap
-- handling in reports with coalesce(product_category_name, 'uncategorized')