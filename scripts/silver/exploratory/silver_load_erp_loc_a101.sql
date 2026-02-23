insert into silver.erp_loc_a101(
    cid,
    cntry
)

select 
replace (cid,'-','') as cid,
case 
when trim(cntry)='DE' then 'Germany'
when trim(cntry) in ('US','USA') then 'United States'
when trim(cntry) = '' or trim(cntry) is null then 'N/A'
else cntry
end as cnrty
from bronze.erp_loc_a101;

-- view table
select * from 
silver.erp_loc_a101;

-- check country
select distinct(cntry)
from silver.erp_loc_a101;