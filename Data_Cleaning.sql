USE gdb023;

-- Removing Duplicates
-- Standardize the Data
-- Null or blank values
-- Removing any unneccessary columns

-- Checking for duplicates

WITH duplicate_cte AS
(SELECT *,ROW_NUMBER() OVER(PARTITION BY product_code) as row_num
FROM fact_gross_price
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
-- Creating a stored procedure for checking duplicate rows using row number and CTE

DELIMITER //
DROP PROCEDURE IF EXISTS GetDuplicates;
CREATE PROCEDURE GetDuplicates(IN table_name VARCHAR(255), 
								IN col1_name VARCHAR(255),
								IN col2_name VARCHAR(255))
BEGIN
    -- Create a dynamic SQL query string
    SET @sql = CONCAT(
        'SELECT * FROM (',
            'SELECT *, ROW_NUMBER() OVER (PARTITION BY ', col1_name,', ', col2_name, ') AS row_num ',
            'FROM ', table_name,
        ') AS duplicate_cte WHERE row_num > 1'
    );
    
    -- Prepare the dynamic SQL
    PREPARE stmt FROM @sql;
    
    -- Execute the prepared statement
    EXECUTE stmt;
    
    -- Deallocate the prepared statement to free up resources
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;

CALL GetDuplicates('dim_customer','customer_code');
CALL GetDuplicates('dim_product','product_code');
CALL GetDuplicates('fact_gross_price','product_code');
CALL GetDuplicates('fact_manufacturing_cost','product_code','cost_year');
CALL GetDuplicates('fact_pre_invoice_deductions','customer_code');
CALL GetDuplicates('fact_sales_monthly','product_code'); -- Include another variable in the def. of stored procedure


/* Standardizing the data
1. String Standardization
2. Date Standardization
3. Numeric Standardization
4. Address Standardization
5. Categorical Data Standardization
6. Removing Duplicates
7. Data Type Conversion
8. Validation Constraints */
-- There are no Duplicates in the dataset
-- There's nothing to standardize, the data is clean
-- There are no NULL Values in the dataset
-- There are no unnecessary columns, No need to remove/drop any Column



















































































