/*

=========================================================
Exploratory Data Analysis : crm
=========================================================

*/


-- ===================================================================================== -- 
-- ==================== Customer Information Table : cst_info ========================== --
-- ===================================================================================== -- 

SELECT
*
FROM Bronze.crm_cust_info


-- Check For Null or Duplicates in Primary Key
-- Expectation : No result 
-- Result  :
-- 6 records where the cst_id had duplicates and three records with NULL cst_ids

-- Solution -- 
-- Aggregate the cst_id where count is > 1. Therefore these records are duplicate
SELECT 
cst_id,
COUNT(*)
FROM Bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
-- Showing NULL Values in the primary key column --
SELECT
cst_id
FROM Bronze.crm_cust_info
WHERE cst_id is NULL


-- Check for Unwanted strings in the names columns 
-- Expectation : No unwanted spaces
-- Result : 15 customers and 17 customers in the first and last name column respectivly with unwanted spaces

SELECT
cst_firstname
FROM Bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT
cst_lastname
FROM Bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)


-- Check for distinct values in then gender
-- Result : 3 distinct values: M, F, NULL
-- Solution : We want to impart a rule where all single characters are full realised. i.e. F = Female, M = Male

SELECT
DISTINCT cst_gndr
FROM Bronze.crm_cust_info


SELECT
DISTINCT cst_marital_status
FROM Bronze.crm_cust_info




-- ===================================================================================== -- 
-- ==================== Product Information Table : crm_prd_info ========================== --
-- ===================================================================================== -- 

-- Check for Duplicate / Null Values in the primary key (prd_column) 
-- Expectation no null or duplicate values
-- Results : No null or duplicate values

SELECT
*
FROM Bronze.crm_prd_info

SELECT 
prd_id,
COUNT(*)
FROM Bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(prd_id) > 1 OR prd_id IS NULL


-- Check for any unwanted spaces in prd_key and prd_nm colum 
-- Expection : No unwanted spaces in either column
-- Result: No unwanted spaces in either column

SELECT
prd_nm,
prd_key
FROM Bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) 
OR prd_key != TRIM(prd_key)


-- Check the distinct values in the prd_line 

SELECT 
prd_line,
COUNT(*) AS count_prd_line
FROM Bronze.crm_prd_info
GROUP BY prd_line
ORDER BY COUNT(prd_line) DESC

-- These needs to be standardised with full names as before

-- Data logic: 
-- Expectation: The start date should be before the end date
-- Result : The start date is after the end date for each product 
-- Solution (See transformation file) 

SELECT
*
FROM Bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt OR prd_end_dt IS NULL

-- ===================================================================================== -- 
-- ==================== Sales Details : crm_sales_details ========================== --
-- ===================================================================================== -- 


SELECT
*
FROM Bronze.crm_sales_details

-- We need to change the data type of sls_order_dt, sls_ship_dt and sls_due_dt from INT to DATE 

-- Let's check if there are negative numbers or 0s
-- Expectations  : No negative or 0 Values
-- Result : 17 rows with 0 vales 
-- Solution : Change 0 to NULL

SELECT
sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt <= 0

-- Dates are in the format YYYYMMDD Therefore, if there are values that are not 8 in length then we need to remove them 

SELECT
sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 

-- order date should alwasy be before ship date
-- None present 

SELECT
sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 OR sls_order_dt > sls_ship_dt


-- Ensure that sls_sales = Quantity * Price and there are no negative, zero or nulls 
-- Result : sls_sales contains nulls, 0s and negative values
-- sls_quantity looks fine 
-- sls_price contains nulls, 0s and negative values (not corresponding to the same null, 0 and negative rows from sls_sales)

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM Bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR sls_sales IS NULL OR sls_sales <= 0
OR sls_quantity IS NULL OR sls_quantity <=0
OR sls_price IS NULL OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price ASC

-- FIX: 
--  If sales is negative, zero or null, derive it from quantity and price 
-- if price is zero or null calculate it using sales and quantity 
-- if price is negative use the ABS() to get the positive value

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales != sls_quantity * ABS(sls_price) OR sls_sales IS NULL OR sls_sales <= 0
	THEN (sls_quantity * ABS(sls_price))
	ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <= 0 
	THEN sls_sales/ NULLIF(sls_quantity, 0) -- if quantity is ever 0 it is replaced with null, which will mean you are not dividing by 0 
	WHEN sls_price != ABS(sls_price)
	THEN ABS(sls_price)
	ELSE sls_price
END AS sls_price
FROM Bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR sls_sales IS NULL OR sls_sales <= 0
OR sls_quantity IS NULL OR sls_quantity <=0
OR sls_price IS NULL OR sls_price <=0
ORDER BY sls_sales, sls_price ASC