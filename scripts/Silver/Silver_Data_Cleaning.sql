/*

=========================================================
Data Cleaning : crm
=========================================================

*/

-- ===================================================================================== -- 
-- ==================== Customer Information Table : cst_info ========================== --
-- ===================================================================================== -- 


-- Removing NULL and Duplicate values from the cst_id column of cst_info

/* Focus on one record where the cst_id is duplicated  (example 29466) and see what is causing the duplication */

SELECT
*
FROM Bronze.crm_cust_info
WHERE cst_id = 29466

/* 
There are three records for 29466, with multiple creation dates, we will keep the latest creation date for all duplicated record and delete the rest
*/

-- Isolate the records where the creation date is not 1 : These are duplicate records and the ones we want to remove

SELECT
*
FROM (
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_lastest_create_date
FROM Bronze.crm_cust_info
)t WHERE flag_lastest_create_date != 1

-- ========================== Transformations =================================== --

-- Removed NULL and Duplicate Values:
SELECT
*
FROM (
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_lastest_create_date
FROM Bronze.crm_cust_info
WHERE cst_id IS NOT NULL -- Removes NULL Values
)t WHERE flag_lastest_create_date = 1 -- Isolates the most recent creation date for each record. 


-- Removed NULL and Duplicate Values
-- Removing unwanted spaces from first and last name columns
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
FROM (
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_lastest_create_date
FROM Bronze.crm_cust_info
WHERE cst_id IS NOT NULL
)t WHERE flag_lastest_create_date = 1 


-- Removed NULL and Duplicate Values
-- Removed unwanted spaces from first and last name columns
-- Data standardisation : F = Female, M = Male
-- Data standardisation marrital_status : M = Married, S = Single
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	ELSE 'N/A'
END cst_marital_status,
CASE 
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	ELSE 'N/A'
END cst_gndr,
cst_create_date
FROM (
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_lastest_create_date
FROM Bronze.crm_cust_info
WHERE cst_id IS NOT NULL
)t WHERE flag_lastest_create_date = 1 



-- ===================================================================================== -- 
-- ==================== Product Information Table : crm_prd_info ========================== --
-- ===================================================================================== -- 


-- ========================== Transformations =================================== --


-- Extract the product category information from the prd_key colum 
/* The first 5 characters of the product key is the category number which is stored in the erp_prd_cat  table 
	However, the cat_id in the erp_prd_cat table has _ rather than - */

SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM Bronze.crm_prd_info

-- Identify where the cat_id in this table is not in the product catelogue table from the erp files
-- One cat_id CO_PE is not in the category table

SELECT
*
FROM(
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM Bronze.crm_prd_info)t WHERE cat_id NOT IN (SELECT DISTINCT ID FROM Bronze.erp_px_cat_g1v2)

-- Isolate the last digits of digits of the prd_key which matches with the sls_prd_key column in the crm_sales_details
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM Bronze.crm_prd_info

-- SIDE QUEST -- 

-- Check any prd_keys that are not in the sales details table; 
-- These producs do not have any orders. 
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM Bronze.crm_prd_info 
WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) NOT IN (SELECT sls_prd_key FROM Bronze.crm_sales_details) 

-- These products all have sales associated with them : 
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
	prd_cost
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM Bronze.crm_prd_info 
WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) IN (SELECT sls_prd_key FROM Bronze.crm_sales_details) 


-- END --

-- Remove the Null values from prd_cost

SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM Bronze.crm_prd_info 



-- Fix Date Logic so that the end data for each record is the start date for the next record - 1
-- Solution : 
/* 
LEAD() window function takes a column and an integer offset as an argument and returns the value of the cell
in that column that is the specified number of rows after the current row. 

*/


SELECT
prd_key,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt, 1) OVER (
	PARTITION BY prd_key ORDER BY prd_start_dt) AS next_month_sales
FROM Bronze.crm_prd_info
WHERE prd_key IN ('CL-JE-LJ-0192-M', 'CL-JE-LJ-0192-L')

-- Fixing Logic where end date is less than start date 

/* An easy fix for this would be to just swap the columns around, however this leaves some cases where the cost of the product would be different within the same year range : 

example: 

Origianl : 
212	AC-HE-HL-U509-R	AC_HE	HL-U509-R	Sport-100 Helmet- Red	12	S 	2011-07-01	2007-12-28
213	AC-HE-HL-U509-R	AC_HE	HL-U509-R	Sport-100 Helmet- Red	14	S 	2012-07-01	2008-12-27
214	AC-HE-HL-U509-R	AC_HE	HL-U509-R	Sport-100 Helmet- Red	13	S 	2013-07-01	NULL

Swapping Start and End Dates: 

212	AC-HE-HL-U509-R	AC_HE	HL-U509-R	Sport-100 Helmet- Red	12	S 	2007-12-28	2011-07-01
213	AC-HE-HL-U509-R	AC_HE	HL-U509-R	Sport-100 Helmet- Red	14	S 	2008-12-27	2012-07-01
214	AC-HE-HL-U509-R	AC_HE	HL-U509-R	Sport-100 Helmet- Red	13	S 	NULL		2013-07-01

As you can see the price for the above product is 12 between 2007 and 2011 but 14 between 2008 and 2012, meaning that in 2010 the price for the above product was 12 and 14 at the same time

======
The Fix
======

We will take the start date from the end date, but make the end date from the start date of the next record - 1, so : 

212	AC-HE-HL-U509-R	AC_HE	HL-U509-R	Sport-100 Helmet- Red	12	S 	2007-12-28	2008-12-26
213	AC-HE-HL-U509-R	AC_HE	HL-U509-R	Sport-100 Helmet- Red	14	S 	2008-12-27	NULL
214	AC-HE-HL-U509-R	AC_HE	HL-U509-R	Sport-100 Helmet- Red	13	S 	NULL		NULL

*/

SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS sls_prd_key,
    prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
    CASE 
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
		ELSE 'N/A'
	END prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST (
		DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS date 
		) AS prd_end_dt
FROM Bronze.crm_prd_info



-- ===================================================================================== -- 
-- ==================== Sales Details : crm_sales_details ========================== --
-- ===================================================================================== -- 

SELECT
*
FROM Bronze.crm_sales_details

-- We need to change the data type of sls_order_dt, sls_ship_dt and sls_due_dt from INT to DATE 
-- 1st change 0 values to null



SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS varchar) AS date) -- cast INT as Varchar first then cast as date
END AS sls_order_dt,
CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt AS varchar) AS date) 
END AS sls_ship_dt,
CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=8 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS varchar) AS date) 
END AS sls_due_dt,
CASE WHEN sls_sales != sls_quantity * ABS(sls_price) OR sls_sales IS NULL OR sls_sales <= 0 -- check if sls_sales is not quantity * price, or if any 0 or null values
	THEN (sls_quantity * ABS(sls_price)) -- if so get the sales as a function of quantity and price
	ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <= 0  
	THEN sls_sales/ NULLIF(sls_quantity, 0) -- if quantity is ever 0 it is replaced with null, which will mean you are not dividing by 0 
	WHEN sls_price != ABS(sls_price) -- if price is negatie
	THEN ABS(sls_price)
	ELSE sls_price
END AS sls_price
FROM Bronze.crm_sales_details

-- At this stage I changed the DDL to reflect the change in data type of sls_*_dt from INT to date format