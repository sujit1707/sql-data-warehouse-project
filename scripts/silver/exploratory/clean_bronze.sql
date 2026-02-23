-- check for nulls or duplicates in primary key
with freq as (select cst_id, count(*) as frequency
from bronze.crm_cust_info 
group by cst_id
having count(*) > 1 or cst_id is null)

select *
from bronze.crm_cust_info b
join freq f  
on f.cst_id=b.cst_id;

-- remove mutiple occurences of cst_id from crm_cust_info
-- select the non-null cst_id with most recent cst_create_date
select *
from (
select *,
row_number() over(PARTITION BY cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info 
where cst_id is not null) t
where flag_last=1


-- check for unwanted spaces in string columns
select *
from bronze.crm_cust_info 
where 
cst_firstname != TRIM(cst_firstname) or
cst_lastname != TRIM(cst_lastname);

-- remvove leading and trailing spaces from cst_firstname and cst_lastname
select cst_id,cst_key, TRIM(cst_firstname) as cst_firstname, TRIM(cst_lastname) as cst_lastname, cst_material_status, cst_gndr,
cst_create_date
from bronze.crm_cust_info ;

-- data standardization and consistency
select distinct cst_gndr
from bronze.crm_cust_info ;

select distinct cst_material_status
from bronze.crm_cust_info ;

-- Male for M , Female for F , N/A otherwise
-- Single for S, Married for M , N/A otherwise

select
case 
when UPPER(TRIM(cst_material_status)) = 'S' then 'Single'
when UPPER(TRIM(cst_material_status)) = 'M' then 'Married'
else 'N/A' 
end as cst_material_status,
CASE
when UPPER(TRIM(cst_gndr))='M' then 'Male'
when UPPER(TRIM(cst_gndr))='F' then 'Female'
else 'N/A'
end as cst_gndr
from bronze.crm_cust_info ;

-- The entire cleaned table

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

