select * 
FROM bronze.erp_loc_a101;

-- check cid 
select cid 
from bronze.erp_loc_a101;
-- transform cid , remove '-' from cid to match cst_key from crp_cust_info
select replace (cid,'-','') as cid
from bronze.erp_loc_a101;
-- match cid with cst_key from crm_cust_info
-- expectation : no result
select cst_key
from silver.crm_cust_info
where cst_key not in (select replace(cid,'-','') from bronze.erp_loc_a101)

-- check country for data consistency and standardization
select distinct cntry
from bronze.erp_loc_a101;
-- tansform cntry
select 
case 
when trim(cntry)='DE' then 'Germany'
when trim(cntry) in ('US','USA') then 'United States'
when trim(cntry) = '' or trim(cntry) is null then 'N/A'
else cntry
end as cnrty
from bronze.erp_loc_a101;

-- entire cleaned table
select 
replace (cid,'-','') as cid,
case 
when trim(cntry)='DE' then 'Germany'
when trim(cntry) in ('US','USA') then 'United States'
when trim(cntry) = '' or trim(cntry) is null then 'N/A'
else cntry
end as cnrty
from bronze.erp_loc_a101;
