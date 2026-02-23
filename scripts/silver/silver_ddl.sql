-- ======================================================
-- Silver DDL Script
-- Creates all silver layer tables
--
-- HOW TO RUN:
-- From project root folder (DataWarehouse):
-- & "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d datawarehouse -f scripts/silver/silver_ddl.sql
--
-- ======================================================


-- make sure you're connected to the DataWarehouse database
select current_database();

-- make sure that schema silver exists
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('bronze', 'silver', 'gold');

\set ON_ERROR_STOP on

drop table if exists silver.crm_cust_info;
create table silver.crm_cust_info (
cst_id int,
cst_key varchar(50),
cst_firstname varchar(50),
cst_lastname varchar(50),
cst_marital_status varchar(50),
cst_gndr varchar(50),
cst_create_date DATE,
dwh_create_date timestamptz default CURRENT_TIMESTAMP 
);

drop table if exists silver.crm_prd_info;
create table silver.crm_prd_info(
prd_id int,
cat_id VARCHAR(50),
prd_key varchar(50),
prd_nm varchar(50),
prd_cost int,
prd_line varchar(50),
prd_start_dt timestamp  ,
prd_end_dt timestamp,
dwh_create_date timestamptz default CURRENT_TIMESTAMP
);

drop table if exists silver.crm_sales_details;
create table silver.crm_sales_details(
sls_ord_num varchar(50),
sls_prd_key varchar(50),
sls_cust_id int,
sls_order_dt date,
sls_ship_dt date,
sls_due_dt date,
old_sls_sales int,
old_sls_quantity int,
old_sls_price int,
sls_sales int,
sls_quantity int,
sls_price int,
dwh_create_date timestamptz default CURRENT_TIMESTAMP
);

drop table if exists silver.erp_loc_a101;
create table silver.erp_loc_a101(
cid varchar(50),
cntry varchar(50),
dwh_create_date timestamptz DEFAULT CURRENT_TIMESTAMP
);

drop table if exists silver.erp_cust_az12;
create table silver.erp_cust_az12(
cid varchar(50),
bdate date,
gen varchar(50),
dwh_create_date timestamptz DEFAULT CURRENT_TIMESTAMP
);

drop table if exists silver.erp_px_cat_g1v2 ;
create table silver.erp_px_cat_g1v2 (
id varchar(50),
cat varchar(50),
subcat varchar(50),
maintenance varchar(50),
dwh_create_date timestamptz DEFAULT CURRENT_TIMESTAMP
);

