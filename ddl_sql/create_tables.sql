CREATE SCHEMA IF NOT EXISTS assignment2;
SET search_path TO assignment2;

CREATE TABLE IF NOT EXISTS customers_raw (
  customer_id INTEGER,
  email TEXT,
  phone TEXT,
  country_code TEXT,
  updated_at TIMESTAMP,
  created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders_raw (
  order_id INTEGER,
  customer_id INTEGER,
  product_id TEXT,
  amount NUMERIC,
  created_at TIMESTAMP,
  currency TEXT
);

CREATE TABLE IF NOT EXISTS products_raw (
  product_id TEXT,
  product_name TEXT,
  category TEXT,
  active_flag CHAR(1)
);

CREATE TABLE IF NOT EXISTS country_dim (
  country_name TEXT,
  iso_code TEXT
);
