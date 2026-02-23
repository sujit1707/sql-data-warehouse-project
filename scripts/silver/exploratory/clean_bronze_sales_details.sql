-- view bronze.crm_sales_details
select *
from bronze.crm_sales_details;
-- get information about table
SELECT
  column_name,
  data_type,
  numeric_precision,
  numeric_scale
FROM information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name = 'crm_sales_details';


-- check sls_order_dt integrity
select sls_order_dt,count(*)
from bronze.crm_sales_details
where length(sls_order_dt::text)!=8
group by sls_order_dt;
-- check sls_ship_dt integrity
select count(*)
from bronze.crm_sales_details
where length(sls_ship_dt::text)!=8
-- check sls_due_dt integrity
select count(*)
from bronze.crm_sales_details
where length(sls_due_dt::text)!=8

-- convert to date data type
select 
case when sls_order_dt::text ~ '^[0-9]{8}$'
and sls_order_dt >19000101 and sls_order_dt < 20500101
and to_char(to_date(sls_order_dt::text,'yyyymmdd'),'yyyymmdd')=sls_order_dt::text
then to_date(sls_order_dt::text,'yyyymmdd')
else NULL
end as sls_order_dt,
case when sls_ship_dt::text ~ '^[0-9]{8}$'
and sls_ship_dt >19000101 and sls_ship_dt < 20500101
and to_char(to_date(sls_ship_dt::text,'yyyymmdd'),'yyyymmdd')=sls_ship_dt::text
then to_date(sls_ship_dt::text,'yyyymmdd')
else NULL
end as sls_ship_dt,
case when sls_due_dt::text ~ '^[0-9]{8}$'
and sls_due_dt >19000101 and sls_due_dt < 20500101
and to_char(to_date(sls_due_dt::text,'yyyymmdd'),'yyyymmdd')=sls_due_dt::text
then to_date(sls_due_dt::text,'yyyymmdd')
else NULL
end as sls_due_dt
from bronze.crm_sales_details;

-- check for invalid date orders 
-- expectation : no result 
with cleaned_dates as (
select 
case when sls_order_dt::text ~ '^[0-9]{8}$'
and sls_order_dt >19000101 and sls_order_dt < 20500101
and to_char(to_date(sls_order_dt::text,'yyyymmdd'),'yyyymmdd')=sls_order_dt::text
then to_date(sls_order_dt::text,'yyyymmdd')
else NULL
end as sls_order_dt,
case when sls_ship_dt::text ~ '^[0-9]{8}$'
and sls_ship_dt >19000101 and sls_ship_dt < 20500101
and to_char(to_date(sls_ship_dt::text,'yyyymmdd'),'yyyymmdd')=sls_ship_dt::text
then to_date(sls_ship_dt::text,'yyyymmdd')
else NULL
end as sls_ship_dt,
case when sls_due_dt::text ~ '^[0-9]{8}$'
and sls_due_dt >19000101 and sls_due_dt < 20500101
and to_char(to_date(sls_due_dt::text,'yyyymmdd'),'yyyymmdd')=sls_due_dt::text
then to_date(sls_due_dt::text,'yyyymmdd')
else NULL
end as sls_due_dt
from bronze.crm_sales_details)

select * from cleaned_dates
where sls_order_dt > sls_ship_dt
or sls_order_dt > sls_due_dt;

-- check sls_ord_num for duplicate , null values, data integrity
select sls_ord_num
from bronze.crm_sales_details
where sls_ord_num != trim(sls_ord_num) or sls_ord_num is null;

select count(*)
from bronze.crm_sales_details
group by sls_ord_num
having count(*) > 1;


-- check sls_prd_key against prd_key of prd_info table (for data integration)
-- expectation : no result (all sls_prd_key match in prd_key of prd_info)
select sls_prd_key
from bronze.crm_sales_details
where sls_prd_key not in (select prd_key from silver.crm_prd_info);

-- check sls_cust_id against cst_id of cust_info(for data integration)
-- expectation : no result
select sls_cust_id
from bronze.crm_sales_details
where sls_cust_id not in (select cst_id from silver.crm_cust_info);

-- check sales , qualtity and price 
-- if sales is -ve, zero or null, derive it from quantity and price
-- if price is zero or null , derive it using sales and qunatity
-- if price is negative , convert it to a positive value
select 
sls_sales, sls_quantity, sls_price
from bronze.crm_sales_details
where sls_sales != sls_price*sls_quantity
or sls_sales is null or  sls_quantity is null or  sls_price is NULL
or sls_sales<=0 or  sls_quantity <=0 or  sls_price <=0 ; 

select
sls_sales as old_sls_sales, sls_quantity as old_sls_quantity, sls_price as old_sls_price,
case
when (sls_sales is null or sls_sales<=0 or sls_sales!= abs(sls_quantity*sls_price) )
and sls_quantity >0 
then abs(sls_price*sls_quantity)
else sls_sales
end as sls_sales, 
case when (sls_price is null or sls_price = 0 ) and sls_sales >0 and sls_quantity>0
then sls_sales/sls_quantity
when sls_price <0 then abs(sls_price)
else sls_price
end as sls_price,
case when sls_quantity <0 then abs(sls_quantity)
else sls_quantity
end as sls_quantity
from bronze.crm_sales_details;

-- the entire cleaned/transformed table
select sls_ord_num, sls_prd_key, sls_cust_id,
case when sls_order_dt::text ~ '^[0-9]{8}$'
and sls_order_dt >19000101 and sls_order_dt < 20500101
and to_char(to_date(sls_order_dt::text,'yyyymmdd'),'yyyymmdd')=sls_order_dt::text
then to_date(sls_order_dt::text,'yyyymmdd')
else NULL
end as sls_order_dt,
case when sls_ship_dt::text ~ '^[0-9]{8}$'
and sls_ship_dt >19000101 and sls_ship_dt < 20500101
and to_char(to_date(sls_ship_dt::text,'yyyymmdd'),'yyyymmdd')=sls_ship_dt::text
then to_date(sls_ship_dt::text,'yyyymmdd')
else NULL
end as sls_ship_dt,
case when sls_due_dt::text ~ '^[0-9]{8}$'
and sls_due_dt >19000101 and sls_due_dt < 20500101
and to_char(to_date(sls_due_dt::text,'yyyymmdd'),'yyyymmdd')=sls_due_dt::text
then to_date(sls_due_dt::text,'yyyymmdd')
else NULL
end as sls_due_dt,
sls_sales::int as old_sls_sales, sls_quantity::int as old_sls_quantity, sls_price::int as old_sls_price,
case
when (sls_sales is null or sls_sales<=0 or sls_sales!= abs(sls_quantity*sls_price) )
and sls_quantity >0 
then abs(sls_price*sls_quantity)
else sls_sales
end as sls_sales, 
case when (sls_price is null or sls_price = 0 ) and sls_sales >0 and sls_quantity>0
then sls_sales/sls_quantity
when sls_price <0 then abs(sls_price)
else sls_price
end as sls_price,
case when sls_quantity <0 then abs(sls_quantity)
else sls_quantity
end as sls_quantity

from bronze.crm_sales_details;
