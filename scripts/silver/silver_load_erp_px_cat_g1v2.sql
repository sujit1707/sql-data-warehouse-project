insert into silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintenance
)
select 
id,
cat,
replace(subcat,'-',' ') as subcat,
maintenance
from bronze.erp_px_cat_g1v2;

-- view table
select *
from silver.erp_px_cat_g1v2;