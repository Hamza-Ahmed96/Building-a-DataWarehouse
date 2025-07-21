INSERT INTO Silver.crm_cust_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
)


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


SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'crm_prd_info'

INSERT INTO Silver.crm_prd_info (
prd_id,
prd_key,
cat_id,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)

SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
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


SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'crm_sales_details'

INSERT INTO Silver.crm_sales_details (
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)

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


SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'erp_cust_az12'

INSERT INTO Silver.erp_cust_az12 (

cid,
bdate,
gen
)

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

INSERT INTO Silver.erp_loc_a101 (
cid,
cntry)

SELECT
REPLACE(cid, '-', '') AS cid,
CASE 
	WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
	WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
	WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
	ELSE cntry
END AS cntry
FROM Bronze.erp_loc_a101


INSERT INTO Silver.erp_px_cat_g1v2
(	id,
    cat,
    subcat,
    maintenance
	  
)

SELECT
*
FROM Bronze.erp_px_cat_g1v2