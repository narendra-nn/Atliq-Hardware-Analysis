USE gdb023;

-- Adding Primary keys and Foreign key constraints

-- dim_customer
-- Primary Key
ALTER TABLE dim_customer
ADD PRIMARY KEY(customer_code);

-- dim_product
-- Primary Key
ALTER TABLE dim_product
ADD PRIMARY KEY(product_code);

-- fact_pre_invoice_deductions
-- Primary key
ALTER TABLE fact_pre_invoice_deductions
ADD PRIMARY KEY(customer_code,fiscal_year);
-- Foreign key
 ALTER TABLE fact_pre_invoice_deductions
 ADD CONSTRAINT fk_pre_invoice_deduction_customer
	FOREIGN KEY (customer_code) REFERENCES dim_customer(customer_code);

-- fact_manufacturing_cost
-- Primary Key
 ALTER TABLE fact_manufacturing_cost
 ADD PRIMARY KEY(product_code,cost_year);
-- Foreign key
ALTER TABLE fact_manufacturing_cost
ADD CONSTRAINT fk_fact_manufacturing_cost_prod_code
	FOREIGN KEY (product_code) REFERENCES dim_product(product_code);

-- fact_gross_price
-- Primary Key
ALTER TABLE fact_gross_price
ADD PRIMARY KEY(product_code,fiscal_year);
-- Foreign key
ALTER TABLE fact_gross_price
ADD CONSTRAINT fk_fact_gross_price
	FOREIGN KEY (product_code) REFERENCES dim_product(product_code);

-- fact_sales_monthly
-- Primary Key
ALTER TABLE fact_sales_monthly
ADD PRIMARY KEY(`date`,product_code,customer_code);
-- Foreign Key
ALTER TABLE fact_sales_monthly
ADD CONSTRAINT fk_sales_monthly_pro
	FOREIGN KEY (product_code) REFERENCES dim_product(product_code);
ALTER TABLE fact_sales_monthly
ADD CONSTRAINT fact_sales_monthly_cust
	FOREIGN KEY (customer_code) REFERENCES dim_customer(customer_code);



























