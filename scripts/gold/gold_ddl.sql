/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

\set ON_ERROR_STOP on

drop view if exists gold.fact_sales;
drop view if exists gold.dim_customers;
drop view if exists gold.dim_products;

-- create dimension - customers as view 

create or replace view gold.dim_customers as
select 
row_number() over(order by ci.cst_id) as customer_key, --surrogate key
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
la.cntry as country,
case
when ci.cst_gndr != 'N/A' then ci.cst_gndr -- CRM is the master for gender info
else COALESCE(ca.gen, 'N/A')
end as gender,
ca.bdate as birthdate,
ci.cst_marital_status as marital_status, 
ci.cst_create_date as create_date 
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key=ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key = la.cid;


-- create dimension-products as view

create or replace view  gold.dim_products as
select 
row_number() over(order by pi.prd_start_dt, pi.prd_key) as product_key,-- surrogate key
pi.prd_id as product_id,
pi.prd_key as product_number,
pi.prd_nm as product_name,
pi.prd_line as product_line,
pi.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pi.prd_cost as cost,
pc.maintenance,
pi.prd_start_dt as start_date
from silver.crm_prd_info pi
join silver.erp_px_cat_g1v2 pc
on pi.cat_id = pc.id
where pi.prd_end_dt is null; -- filter out historical data

-- create fact-sales as view

create or replace view gold.fact_sales as 
select sd.sls_ord_num,
p.product_key,
c.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd
left join gold.dim_customers c
on sd.sls_cust_id = c.customer_id
left join gold.dim_products p
on sd.sls_prd_key = p.product_number;

------------------------------------------------------

-- check foreign key data integrity in gold.fact_sales
select 
s.product_key ,
p.product_key,
s.customer_key,
c.customer_key

from gold.fact_sales s
left join gold.dim_products p
on s.product_key = p.product_key
left join gold.dim_customers c
on s.customer_key = c.customer_key
where p.product_key is null or c.customer_key is null;