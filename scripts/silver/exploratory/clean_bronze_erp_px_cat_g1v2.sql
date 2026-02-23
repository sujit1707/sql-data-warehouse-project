select * from 
bronze.erp_px_cat_g1v2;

-- match id with cat_id of crm_prd_info table
select id
from bronze.erp_px_cat_g1v2
where id not in
(select cat_id
from silver.crm_prd_info);

-- check category - cat column for data consistency and standardization
-- expectation : no result
select distinct cat
from bronze.erp_px_cat_g1v2
where trim(cat) != cat;

-- check subcat column for data consistency and standardization
select distinct subcat
from bronze.erp_px_cat_g1v2;

-- transform subcat column ,replace '-' with ''
select distinct replace(trim(subcat),'-',' ') as subcat
from bronze.erp_px_cat_g1v2;

-- check maintenance column
select distinct maintenance
from bronze.erp_px_cat_g1v2;

-- entire cleaned table
select 
id,
cat,
replace(subcat,'-',' ') as subcat,
maintenance
from bronze.erp_px_cat_g1v2;
