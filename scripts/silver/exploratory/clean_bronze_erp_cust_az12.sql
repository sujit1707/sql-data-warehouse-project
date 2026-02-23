select * from bronze.erp_cust_az12;

-- get info about table
SELECT
  column_name,
  data_type,
  numeric_precision,
  numeric_scale
FROM information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name = 'erp_cust_az12';

-- check duplicate customer id - cid
-- expectation: no result
select cid , count(*)
from bronze.erp_cust_az12
group by cid
having count(*)>1 ;

-- match cid with cst_key of crm_cust_info table
select cid
from bronze.erp_cust_az12
where cid not in (select cst_key from silver.crm_cust_info);

select cst_key
from silver.crm_cust_info
where cst_key not in (select cid from bronze.erp_cust_az12);
/* we see that cid has an extra 'NAS' in some keys. We can extract the rest 
of the substring from cid to match with cst_key of crm_cust_info*/

-- transform cid and match cid with cst_key
-- expectation : no result
with my_cte as (
select 
case when cid like 'NAS%' then substr(cid,4)
else cid
end as cid
from bronze.erp_cust_az12)
select cid
from my_cte
where cid not in (select cst_key from silver.crm_cust_info);

-- check out-of-range birth dates - bdate
select bdate
from bronze.erp_cust_az12
where bdate < '1910-01-01' or bdate > current_date;
-- transform bdate
select 
case when bdate > current_date then NULL
else bdate
end as bdate
from bronze.erp_cust_az12;

-- check data standardization consistency for gender - gen column
select *
from bronze.erp_cust_az12
where upper(gen) not in ('MALE','FEMALE');
-- transform gen column
select
case 
when upper(trim(gen)) in ('MALE','M') then 'Male'
when upper(trim(gen)) in ('FEMALE','F') then 'Female'
else 'N/A'
end as gen
from bronze.erp_cust_az12;

-- entire clean table
select
case 
when cid like 'NAS%' then substr(cid,4)
else cid
end as cid,
case
when bdate > current_date then NULL
else bdate
end as bdate,
case
when upper(trim(gen)) in ('MALE','M') then 'Male'
when upper(trim(gen)) in ('FEMALE','F') then 'Female'
else 'N/A'
end as gen
from bronze.erp_cust_az12;
