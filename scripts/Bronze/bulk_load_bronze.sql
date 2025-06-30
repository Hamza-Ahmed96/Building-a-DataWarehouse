/*

=====================================================
		LOAD DATA INTO BRONZE LAYER
=====================================================

This script used BULK INSERT to load the data from the csv files on the locatl computer into the correct database tables.
It also outputs the time taken for each table to identify any bottlenecks and errors


*/



CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
-- TRY and Catch to catch and log any errors during the loading steps-- 

	-- Varibles to track how long each table takes to load, to identify any bottlenecks in the data loading steps -- 
	DECLARE 
		@start_time DATETIME, 
		@end_time DATETIME

	BEGIN TRY
		
		SET @start_time = GETDATE();
		TRUNCATE TABLE Bronze.crm_cust_info;

		BULK INSERT Bronze.crm_cust_info
		FROM 'C:\Users\HamzaA\Documents\GitHubProfile\DataAnalyst-Portfolio\Building-a-DataWarehouse\datasets\source_crm\cust_info.csv'
		WITH (

			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'TABLE Bronze.crm_cust_info : ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '-----------------------'

		SET @start_time = GETDATE();
		TRUNCATE TABLE Bronze.crm_prd_info;
		BULK INSERT Bronze.crm_prd_info
		FROM 'C:\Users\HamzaA\Documents\GitHubProfile\DataAnalyst-Portfolio\Building-a-DataWarehouse\datasets\source_crm\prd_info.csv'
		WITH (

			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'TABLE Bronze.crm_prd_info : ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '-----------------------'

		SET @start_time = GETDATE();
		TRUNCATE TABLE Bronze.crm_sales_details;

		BULK INSERT Bronze.crm_sales_details
		FROM 'C:\Users\HamzaA\Documents\GitHubProfile\DataAnalyst-Portfolio\Building-a-DataWarehouse\datasets\source_crm\sales_details.csv'
		WITH (

			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'TABLE Bronze.crm_sales_details : ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '-----------------------'


		SET @start_time = GETDATE();
		TRUNCATE TABLE Bronze.erp_cust_az12;

		BULK INSERT Bronze.erp_cust_az12
		FROM 'C:\Users\HamzaA\Documents\GitHubProfile\DataAnalyst-Portfolio\Building-a-DataWarehouse\datasets\source_erp\CUST_AZ12.csv'
		WITH (

			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'TABLE Bronze.erp_cust_az12 : ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '-----------------------'


		SET @start_time = GETDATE();
		TRUNCATE TABLE Bronze.erp_loc_a101;

		BULK INSERT Bronze.erp_loc_a101
		FROM 'C:\Users\HamzaA\Documents\GitHubProfile\DataAnalyst-Portfolio\Building-a-DataWarehouse\datasets\source_erp\LOC_A101.csv'
		WITH (

			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'TABLE Bronze.erp_loc_a101 : ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '-----------------------'


		SET @start_time = GETDATE();
		TRUNCATE TABLE Bronze.erp_px_cat_g1v2;

		BULK INSERT Bronze.erp_px_cat_g1v2
		FROM 'C:\Users\HamzaA\Documents\GitHubProfile\DataAnalyst-Portfolio\Building-a-DataWarehouse\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (

			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'TABLE Bronze.erp_px_cat_g1v2 : ' +  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '-----------------------'


		END TRY
	BEGIN CATCH
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' + CAST (ERROR_NUMBER() AS NVARCHAR);
	END CATCH
END