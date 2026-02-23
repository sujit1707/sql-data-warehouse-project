insert into silver.erp_cust_az12(
    cid,
    bdate,
    gen
)
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

select * from silver.erp_cust_az12;

-- check bdate
-- expectation : no result
select bdate
from silver.erp_cust_az12
where bdate > current_date;

-- check gender
select distinct gen
from silver.erp_cust_az12;