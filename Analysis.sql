USE gdb023;

SELECT *
FROM fact_sales_monthly;

-- 1. Provide the list of markets in which customer  "Atliq  Exclusive"  operates its business in the  APAC  region.
SELECT DISTINCT market
FROM dim_customer
WHERE customer = "Atliq Exclusive" AND region = "APAC";

-- Atliq Exclusive operates India,Bangladesh,Indonesia,Phillipines,Japan,South Korea,New Zealand and Australia

/* 2.  What is the percentage of unique product increase in 2021 vs. 2020?
The final output contains these fields
unique_products_2020 
unique_products_2021 
percentage_chg */

-- Use Common Table Expressions (CTEs) to count unique products for each year
WITH unique_products_2020 AS (
  SELECT COUNT(DISTINCT product_code) AS count_2020
  FROM fact_sales_monthly
  WHERE fiscal_year = 2020
),
unique_products_2021 AS (
  SELECT COUNT(DISTINCT product_code) AS count_2021
  FROM fact_sales_monthly
  WHERE fiscal_year = 2021
)

-- Calculate the percentage change
SELECT 
  unique_products_2020.count_2020 AS unique_products_2020,
  unique_products_2021.count_2021 AS unique_products_2021,
  ROUND(((unique_products_2021.count_2021 - unique_products_2020.count_2020) / unique_products_2020.count_2020) * 100, 2) AS percentage_chg
FROM 
  unique_products_2020
CROSS JOIN 
  unique_products_2021;

-- Alternative
-- Use a single CTE to calculate unique products for both years
WITH unique_products AS (
  SELECT 
    COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code ELSE NULL END) AS unique_products_2020,
    COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code ELSE NULL END) AS unique_products_2021
  FROM fact_sales_monthly
)

-- Calculate the percentage change
SELECT 
  unique_products.unique_products_2020,
  unique_products.unique_products_2021,
  ROUND(((unique_products.unique_products_2021 - unique_products.unique_products_2020) / unique_products.unique_products_2020) * 100, 2) AS percentage_chg
FROM unique_products;

-- The Percentage of change in unique products from 2020-2021 is 36.33%

/* 3.  Provide a report with all the unique product counts for each  segment  and 
sort them in descending order of product counts. The final output contains 
2 fields, 
segment 
product_count */

SELECT segment,COUNT(DISTINCT(product_code)) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

-- Segments of Notebooks, Accessories and Peripherals has most unique produxts with 129,116,84 respectively

/* 4. Follow-up: Which segment had the most increase in unique products in 
2021 vs 2020? The final output contains these fields, 
segment 
product_count_2020 
product_count_2021 
difference */

WITH segment_unique_products AS (
  SELECT 
    COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN fsm.product_code ELSE NULL END) AS unique_products_2020,
    COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN fsm.product_code ELSE NULL END) AS unique_products_2021,
    segment
  FROM fact_sales_monthly fsm
  INNER JOIN dim_product pro
  ON fsm.product_code = pro.product_code
  GROUP BY segment
)

-- Calculate the difference
SELECT 
  segment,
  segment_unique_products.unique_products_2020,
  segment_unique_products.unique_products_2021,
  (segment_unique_products.unique_products_2021 - segment_unique_products.unique_products_2020) AS difference
FROM segment_unique_products
ORDER BY difference DESC;

-- The Accessories Segment has the most amount of unique product increase from 2020 to 2021 followed by the segments Notebooks and Peripherals

/* 5.  Get the products that have the highest and lowest manufacturing costs. 
The final output should contain these fields, 
product_code 
product 
manufacturing_cost */

SELECT product,fmc.product_code,manufacturing_cost
FROM fact_manufacturing_cost AS fmc
INNER JOIN dim_product AS pro
ON fmc.product_code = pro.product_code
WHERE fmc.manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost) 
OR fmc.manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost);

-- Products 'AQ HOME Allin1 Gen 2' and 'AQ Master wired x1 Ms' has highest and lowest manufacturing costs with cost being "240.5364" and "0.8920" respectively

/* 6.  Generate a report which contains the top 5 customers who received an 
average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the 
Indian  market. The final output contains these fields, 
customer_code 
customer 
average_discount_percentage */

SELECT cus.customer_code,customer,
avg(pre_invoice_discount_pct) AS average_discount_percentage
FROM dim_customer AS cus
INNER JOIN fact_pre_invoice_deductions AS fpid
ON cus.customer_code = fpid.customer_code
WHERE fiscal_year = "2021" AND market = "India"
GROUP BY cus.customer
ORDER BY average_discount_percentage DESC
LIMIT 5;
/* Top 5 Customers who have received average high  pre_invoice_discount_pct
for the  fiscal  year 2021  and in the Indian  market were:

Flipkart with 0.3083
Viveks with 0.3038
Ezone with 0.3028
Croma with 0.3025
Vijay Sales with 0.2753 */

/* 7. Get the complete report of the Gross sales amount for the customer  “Atliq 
Exclusive”  for each month.This analysis helps to  get an idea of low and 
high-performing months and take strategic decisions. 
The final report contains these columns: 
Month 
Year 
Gross sales Amount */

SELECT 
MONTH(`date`) AS `Month`,
YEAR(`date`) AS `Year`,
SUM(sold_quantity*gross_price) AS Gross_Sales_Amount
FROM fact_sales_monthly fsm
INNER JOIN dim_customer AS cus
ON fsm.customer_code = cus.customer_code
INNER JOIN fact_gross_price AS fgp 
ON fsm.product_code = fgp.product_code 
WHERE customer = "Atliq Exclusive"
GROUP BY `Year`, `Month`
ORDER BY `Year`, `Month`;

/* 8. In which quarter of 2020, got the maximum total_sold_quantity? The final 
output contains these fields sorted by the total_sold_quantity, 
Quarter 
total_sold_quantity */
/* Q1:April-june
   Q2:July-Sep
   Q3:Oct-Dec
   Q4:Jan-Mar
   */
   
SELECT QUARTER(`date`) AS `Quarter` , SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year="2020"
GROUP BY `Quarter`
ORDER BY total_sold_quantity DESC;

-- Quarter 4 of the fiscal year 2020 has the highest total_sold_quantity

/* 9.  Which channel helped to bring more gross sales in the fiscal year 2021 
and the percentage of contribution?  The final output  contains these fields, 
channel 
gross_sales_ml */

WITH Channel_gross_Sales_percent AS(
SELECT `channel`,SUM(sold_quantity*gross_price) AS Gross_Sales_Amount
FROM dim_customer AS cus
INNER JOIN fact_sales_monthly AS fsm
ON fsm.customer_code = cus.customer_code
INNER JOIN fact_gross_price AS fgp
ON fgp.product_code = fsm.product_code
WHERE fsm.fiscal_year = "2021"
GROUP BY `channel`),
total_sales AS (
  SELECT SUM(Gross_Sales_Amount) AS total_gross_sales_ml
  FROM Channel_gross_Sales_percent)
  
  -- calculating the percentage
  
  SELECT 
  cs.`channel`,
  cs.Gross_Sales_Amount,
  ROUND((cs.Gross_Sales_Amount / ts.total_gross_sales_ml) * 100, 2) AS percentage_contribution
  FROM Channel_gross_Sales_percent AS cs
  CROSS JOIN 
  total_sales ts
ORDER BY 
  cs.Gross_Sales_Amount DESC;

-- Retail Channel has give most contribution in Gross_Sales_Amount with 75.22% Followed by Direct and Distributor channels with 15.47% and 11.31% respectively

/* 10. Get the Top 3 products in each division that have a high 
total_sold_quantity in the fiscal_year 2021? The final output contains these fields,
 
division 
product_code 
product 
total_sold_quantity 
rank_order */

WITH ranked_products AS (
  SELECT 
    dp.division,
    fsm.product_code,
    dp.product,
    SUM(fsm.sold_quantity) AS total_sold_quantity,
    RANK() OVER (PARTITION BY dp.division ORDER BY SUM(fsm.sold_quantity) DESC) AS rank_order
  FROM 
    fact_sales_monthly fsm
  INNER JOIN 
    dim_product dp ON fsm.product_code = dp.product_code
  WHERE 
    fsm.fiscal_year = 2021
  GROUP BY 
    dp.division, fsm.product_code, dp.product
)

SELECT 
  division,
  product_code,
  product,
  total_sold_quantity,
  rank_order
FROM 
  ranked_products
WHERE 
  rank_order <= 3
ORDER BY 
  division, rank_order;
