/*

=========================================================
Data Cleaning : ERP
=========================================================

*/

-- ===================================================================================== -- 
-- ==================== Customer Information Table : cust_az12 ========================== --
-- ===================================================================================== -- 


-- cid column contains "NAS" which will prevent it from matching to the cst_key column in the cust_info table
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END AS cid,
CAST(
	CASE WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END 
AS date) AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
	WHEN  UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
	ELSE 'n/a'
END AS gen
FROM Bronze.erp_cust_az12 


-- ===================================================================================== -- 
-- ==================== Customer Information Table : loc_a101 ========================== --
-- ===================================================================================== -- 

-- Remove dashes from cid
SELECT
REPLACE(cid, '-', '') AS cid,
cntry
FROM Bronze.erp_loc_a101 

-- 2. In the country column : 
-- US, United States, USA
-- NULL values 332 rows
-- Blank values
-- DE ?

SELECT
REPLACE(cid, '-', '') AS cid,
CASE 
	WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
	WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
	WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
	ELSE cntry
END AS cntry
FROM Bronze.erp_loc_a101

SELECT
*
FROM Bronze.erp_px_cat_g1v2
