SET search_path TO assignment2;

CREATE PUBLICATION hevo_pub_assignment2
FOR TABLE customers_raw, orders_raw, products_raw, country_dim;
