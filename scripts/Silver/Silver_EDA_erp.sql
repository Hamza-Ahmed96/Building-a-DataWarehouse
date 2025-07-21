/*

=========================================================
Exploratory Data Analysis : erp
=========================================================

*/

SELECT
*
FROM Bronze.erp_cust_az12
-- Blank rows in gen column
-- some values in gen column as M/F rather than Male/Female 
-- cid column contains "NASA" which will prevent it from matching to the cst_key column in the cust_info table 

SELECT
*
FROM Silver.crm_cust_info


-- Check if bdate is out of range e.g customers who are older then 100 years or have birthdays in the future 
SELECT
bdate
FROM Bronze.erp_cust_az12
WHERE bdate < DATEADD(YEAR, -100, '2025/01/01') OR bdate > GETDATE()


-- In the location table, there are some issues: 
--	1. '-' in the cid column 
SELECT
cid
FROM Bronze.erp_loc_a101

-- 2. In the country column : 
-- US, United States, USA
-- NULL values 332 rows
-- Blank values
-- DE ?
SELECT DISTINCT
cntry
FROM Bronze.erp_loc_a101


SELECT
*
FROM Bronze.erp_px_cat_g1v2

-- Check for unwanted spaces in the string columns of the product category table
-- No unwanted spaces
SELECT
*
FROM Bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Check Data Standardisation 
-- No errors in data standardisation

SELECT DISTINCT
cat
FROM Bronze.erp_px_cat_g1v2

SELECT DISTINCT
subcat
FROM Bronze.erp_px_cat_g1v2

SELECT DISTINCT
maintenance
FROM Bronze.erp_px_cat_g1v2


