-- ======================================================
-- Bronze Load Script
-- Re-runnable load of raw source data
--
-- HOW TO RUN:
-- From project root folder (DataWarehouse):
-- & "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d datawarehouse -f scripts/bronze/bronze_load.sql

-- ================= CRM =================

\set ON_ERROR_STOP on

-- truncate and load bronze.crm_cust_info;
truncate table bronze.crm_cust_info;
\copy bronze.crm_cust_info from 'dataset/source_crm/cust_info.csv' delimiter ',' csv header
-- check row count
select count(*)  as crm_cust_info_count from bronze.crm_cust_info;

------------------------------------------------------------------

-- truncate and load bronze.crm_prd_info
truncate table bronze.crm_prd_info;
\copy bronze.crm_prd_info from 'dataset/source_crm/prd_info.csv' delimiter ',' csv header 
-- check row count
select count(*) as crm_prd_info_count from bronze.crm_prd_info;

-----------------------------------------------------------------

-- truncate and load bronze.crm_sales_details
truncate table bronze.crm_sales_details;
\copy bronze.crm_sales_details from 'dataset/source_crm/sales_details.csv' delimiter ',' csv header 
-- check row count
select count(*) as crm_sales_details_count from bronze.crm_sales_details;


-- ================= ERP =================


-- truncate and load bronze.erp_cust_az12
truncate table bronze.erp_cust_az12;
\copy bronze.erp_cust_az12 from 'dataset/source_erp/cust_az12.csv' delimiter ',' csv header 
-- check row count
select count(*) as erp_cust_az12_count from bronze.erp_cust_az12;

-----------------------------------------------------------------

-- truncate and load bronze.erp_loc_a101
truncate table  bronze.erp_loc_a101;
\copy bronze.erp_loc_a101 from 'dataset/source_erp/loc_a101.csv' delimiter ',' csv header 
-- check row count
select count(*) as erp_loc_a101_count from bronze.erp_loc_a101;

-----------------------------------------------------------------

-- truncate and load bronze.erp_px_cat_g1v2
truncate table bronze.erp_px_cat_g1v2;
\copy bronze.erp_px_cat_g1v2 from 'dataset/source_erp/px_cat_g1v2.csv' delimiter ',' csv header 
-- check row count
select count(*) as erp_px_cat_g1v2_count from bronze.erp_px_cat_g1v2;
