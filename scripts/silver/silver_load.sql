select current_database();
select schema_name from 
information_schema.schemata
where schema_name in ('bronze','silver','gold')
;

truncate table silver.crm_cust_info;

insert into silver.crm_cust_info(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_material_status,
    cst_gndr,
    cst_create_date)


select cst_id, cst_key, trim(cst_firstname) as cst_firstname, trim(cst_lastname) as cst_lastname,
CASE
when upper(trim(cst_material_status))='M' then 'Married'
when upper(trim(cst_material_status))='S' then 'Single'
else 'N/A'
end as cst_material_status,
CASE
when upper(trim(cst_gndr))='M' then 'Male'
when upper(trim(cst_gndr))='F' then 'Female'
else 'N/A'
end as cst_gndr,
cst_create_date

from (
select *,
row_number() over(PARTITION BY cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info 
where cst_id is not null) t
where flag_last=1;

-- test duplicate cst_id
-- expectation : no result
select cst_id, count(*)
from silver.crm_cust_info
group by cst_id
having count(*)>1;

-- check unwanted spaces in string columns
-- expectation : no result
select cst_key
from silver.crm_cust_info
where cst_key != trim(cst_key);
-------------------------------------------
select cst_firstname
from silver.crm_cust_info
where cst_firstname != trim(cst_firstname);
-------------------------------------------
select cst_lastname
from silver.crm_cust_info
where cst_lastname != trim(cst_lastname);

-- check data standardization and consistency
select distinct cst_material_status
from silver.crm_cust_info;
---------------------------------------------
select distinct cst_gndr
from silver.crm_cust_info;

-- check the whole table
select *
from silver.crm_cust_info;
