drop table if exists silver.crm_sales_details;

create table silver.crm_sales_details(
    sls_ord_num varchar(50),
    sls_prd_key varchar(50),
    sls_cust_id int,
    sls_order_dt date,
    sls_ship_dt date,
    sls_due_dt date,
    old_sls_sales int,
    old_sls_quantity int,
    old_sls_price int,
    sls_sales int,
    sls_quantity int,
    sls_price int,
    dwh_create_date timestamptz default current_timestamp 
);

insert into silver.crm_sales_details(
       sls_ord_num,
    sls_prd_key ,
    sls_cust_id ,
    sls_order_dt ,
    sls_ship_dt ,
    sls_due_dt ,
    old_sls_sales ,
    old_sls_quantity ,
    old_sls_price ,
    sls_sales ,
    sls_quantity ,
    sls_price 
)
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

select * from silver.crm_sales_details;

-- check for invalid date orders
-- expectation : no result
select * from silver.crm_sales_details
where sls_order_dt > sls_due_dt OR
sls_order_dt > sls_ship_dt;

-- check sls_sales, sls_quantity and sls_price
select 
sls_sales, sls_quantity, sls_price
from silver.crm_sales_details
where sls_sales != sls_price*sls_quantity
or sls_sales is null or  sls_quantity is null or  sls_price is NULL
or sls_sales<=0 or  sls_quantity <=0 or  sls_price <=0 ; 