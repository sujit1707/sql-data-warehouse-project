-- view table bronze.crm_prd_info
SELECT *
from bronze.crm_prd_info;

-- obtain info about the crm_prd_info table
SELECT
  column_name,
  data_type,
  numeric_precision,
  numeric_scale
FROM information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name = 'crm_prd_info';


-- check for duplicate primary key prd_id or nulls 
-- expectation : no result
select prd_id, count(*)
from bronze.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null;

-- check unwanted spaces in string columns 
-- expectation : no result
select prd_key
from bronze.crm_prd_info
where prd_key != trim(prd_key) or prd_key is null;
------------------------------------------
select prd_nm
from bronze.crm_prd_info
where prd_nm != trim(prd_nm);

-- parse substring product category id from prd_key and create a new column cat_id
-- replace '-' with '_' in cat_id to match with id in erp category table(erp_px_cat_g1v2)
SELECT
replace(substr(prd_key,1,5),'-','_') as cat_id
from bronze.crm_prd_info;

-- check the cat_id column with id in the category table(erp_px_cat_g1v2)
SELECT distinct
replace(substr(prd_key,1,5),'-','_') as cat_id
from bronze.crm_prd_info
where replace(substr(prd_key,1,5),'-','_')
not in (select id from bronze.erp_px_cat_g1v2);
--(we can see that cat_id from prd_info largely matches the id column in erp_px_cat table)

-- parse substring product key from prd_key and create a new column product_key
-- match with sls_prd_key
select
substr(prd_key,7) as product_key
from bronze.crm_prd_info;

-- check product_key with sls_prd_key 
select
substr(prd_key,7) as product_key
from bronze.crm_prd_info
where substr(prd_key,7) in (select sls_prd_key from bronze.crm_sales_details);

-- check prd_cost column for data type, -ve values , nulls
-- expectation : numeric / integer 
SELECT pg_typeof(prd_cost)
FROM bronze.crm_prd_info
limit 1;
---------------------------------------
select prd_cost
from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null;

-- check prd_line column
-- data standardization and consistency
select distinct prd_line 
from bronze.crm_prd_info;
---------------------------------------
select
CASE upper(trim(prd_line))
when 'M' then 'Mountain'
when 'R' then 'Road'
when 'S' then 'Other Sales'
when 'T' then 'Touring'
else 'N/A'
end as prd_line
from bronze.crm_prd_info;

-- check for invalid date orders
-- if prd_end_dt < prd_start_dt

from bronze.crm_prd_info
where prd_end_dt < prd_start_dt
order by prd_nm;

-- check if two rows in the prd_key window has same start_dt 
SELECT prd_key, prd_start_dt, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_key, prd_start_dt
HAVING COUNT(*) > 1;

-- use prd_start_dt of the same product for the next order as the prd_end_dt for current order
select prd_start_dt,
CASE
when prd_end_dt < prd_start_dt then
lead(prd_start_dt) over(partition by prd_key order by prd_start_dt, prd_id)
else prd_end_dt
end as prd_end_dt
from bronze.crm_prd_info
order by prd_id;

-- The entire cleaned and transformed table 
select prd_id,
replace(substr(prd_key,1,5),'-','_') as cat_id,
substr(prd_key,7) as prd_key,
prd_nm,
prd_cost,
CASE upper(trim(prd_line))
when 'M' then 'Mountain'
when 'R' then 'Road'
when 'S' then 'Other Sales'
when 'T' then 'Touring'
else 'N/A'
end as prd_line,
prd_start_dt, 
CASE
when prd_end_dt < prd_start_dt then
lead(prd_start_dt) over(partition by prd_key order by prd_start_dt, prd_id)
else prd_end_dt
end as prd_end_dt
from bronze.crm_prd_info;


