
drop table if exists silver.crm_prd_info;
create table silver.crm_prd_info(
    prd_id int,
    cat_id varchar(50),
    prd_key varchar(50),
    prd_nm varchar(50),
    prd_cost int,
    prd_line varchar(50),
    prd_start_dt date,
    prd_end_dt date,
    dwh_create_date timestamptz default CURRENT_TIMESTAMP
);

truncate table silver.crm_prd_info;

insert into silver.crm_prd_info(
    prd_id, 
    cat_id ,
    prd_key ,
    prd_nm ,
    prd_cost,
    prd_line,
    prd_start_dt, 
    prd_end_dt
)
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

select * from silver.crm_prd_info;
