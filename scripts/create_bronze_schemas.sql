/*

======================================
Create Bronze Layer Tables 
=====================================

This script creates the tables for the bronze layer, using the header names and object types of the files in the source_crm and source_erp data folders. 


*/

CREATE TABLE Bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date NVARCHAR(50)
);

CREATE TABLE Bronze.crm_prd_info(
  prd_id INT,
  prd_key NVARCHAR(50),
  prd_nm NVARCHAR(50),
  prd_cost FLOAT,
  prd_line NVARCHAR(50),
  prd_start_dt DATETIME,
  prd_end_dt DATETIME
);

CREATE TABLE Bronze.crm_sales_details(

  sls_ord_num NVARCHAR(50),
  sls_prd_key NVARCHAR(50),
  sls_cust_id INT,
  sls_order_dt DATETIME,
  sls_ship_dt DATETIME,
  sls_due_dt DATETIME,
  sls_sales FLOAT,
  sls_quantity INT,
  sls_price FLOAT
);

CREATE TABLE Bronze.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);

CREATE TABLE Bronze.erp_loc_a101(
	
	cid NVARCHAR(50),
	cntry NVARCHAR(50)

);

CREATE TABLE Bronze.ero_pc_cat_g1v2(
	
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)



);