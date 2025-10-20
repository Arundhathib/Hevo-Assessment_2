USE SCHEMA assignment2;

CREATE OR REPLACE TABLE customers_dedup AS
SELECT
  customer_id,
  LOWER(TRIM(email)) AS email,
  CASE
    WHEN LENGTH(REGEXP_REPLACE(COALESCE(phone,''),'[^0-9]','')) = 10
      THEN REGEXP_REPLACE(COALESCE(phone,''),'[^0-9]','')
    ELSE 'Unknown'
  END AS phone,
  country_code,
  updated_at,
  NVL(created_at, TO_TIMESTAMP('1900-01-01 00:00:00')) AS created_at
FROM (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COALESCE(updated_at, created_at) DESC NULLS LAST) AS rn
  FROM RAW_SCHEMA.customers_raw
) t
WHERE rn = 1;

CREATE OR REPLACE TABLE country_norm_helper AS
SELECT * FROM VALUES
  ('USA','US'),
  ('UNITEDSTATES','US'),
  ('UNITED STATES','US'),
  ('US','US'),
  ('IND','IN'),
  ('INDIA','IN'),
  ('SINGAPORE','SG'),
  ('SG','SG')
  AS t(messy, iso);

CREATE OR REPLACE TABLE customers_clean AS
SELECT
  c.customer_id,
  CASE WHEN c.email IS NULL THEN 'Invalid Customer' ELSE c.email END AS email,
  c.phone,
  COALESCE(ch.iso, UPPER(TRIM(c.country_code))) AS country_code,
  c.updated_at,
  c.created_at,
  CASE WHEN c.email IS NULL AND (c.phone IS NULL OR c.phone = 'Unknown') THEN 'Invalid Customer' ELSE 'Valid' END AS validity_flag
FROM customers_dedup c
LEFT JOIN country_norm_helper ch
  ON UPPER(REPLACE(c.country_code,' ','')) = ch.messy;

CREATE OR REPLACE TABLE orders_dedup AS
SELECT order_id, customer_id, product_id, amount, created_at, UPPER(currency) AS currency
FROM (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY order_id, customer_id, product_id, amount, created_at, UPPER(currency) ORDER BY order_id) rn
  FROM RAW_SCHEMA.orders_raw
) t
WHERE rn = 1;

CREATE OR REPLACE TABLE customer_medians AS
SELECT customer_id,
  CASE
    WHEN COUNT(amount) = 0 THEN 0
    ELSE (PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount))
  END AS median_amount
FROM orders_dedup
WHERE amount IS NOT NULL AND amount >= 0
GROUP BY customer_id;

CREATE OR REPLACE TABLE orders_clean AS
SELECT
  o.order_id,
  o.customer_id,
  COALESCE(o.product_id,'Unknown') AS product_id,
  CASE
    WHEN o.amount IS NULL THEN COALESCE(m.median_amount, 0)
    WHEN o.amount < 0 THEN 0
    ELSE o.amount
  END AS amount,
  o.created_at,
  COALESCE(UPPER(o.currency),'USD') AS currency,
  CASE UPPER(COALESCE(o.currency,'USD'))
    WHEN 'USD' THEN amount
    WHEN 'INR' THEN amount * 0.012
    WHEN 'SGD' THEN amount * 0.73
    WHEN 'EUR' THEN amount * 1.10
    ELSE amount
  END AS amount_usd
FROM orders_dedup o
LEFT JOIN customer_medians m ON o.customer_id = m.customer_id;

CREATE OR REPLACE TABLE products_clean AS
SELECT
  product_id,
  INITCAP(LOWER(product_name)) AS product_name,
  INITCAP(LOWER(category)) AS category,
  active_flag
FROM RAW_SCHEMA.products_raw;

CREATE OR REPLACE TABLE final_dataset AS
SELECT
  o.order_id,
  o.customer_id,
  COALESCE(c.email, 'Orphan Customer') AS customer_email,
  COALESCE(c.phone, 'Unknown') AS customer_phone,
  COALESCE(c.country_code, 'Unknown') AS customer_country,
  o.product_id,
  CASE WHEN p.product_id IS NULL THEN 'Unknown Product' ELSE p.product_name END AS product_name,
  CASE WHEN p.active_flag = 'N' THEN 'Discontinued Product' ELSE p.category END AS product_status,
  o.amount,
  o.currency,
  o.amount_usd,
  o.created_at AS order_created_at,
  c.validity_flag
FROM orders_clean o
LEFT JOIN customers_clean c ON o.customer_id = c.customer_id
LEFT JOIN RAW_SCHEMA.products_raw p ON o.product_id = p.product_id;

SELECT * FROM final_dataset LIMIT 10;
