
CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
BEGIN

    -- loading silver.crm_cust_info

    truncate table silver.crm_cust_info;

    insert into silver.crm_cust_info(
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_material_status,
        cst_gndr,
        cst_create_date)

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


    -- loading: silver.crm_prd_info

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

    -- loading table: silver.crm_sales_details

    truncate table silver.crm_sales_details;

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

    -- loading table silver.erp_cust_az12

    truncate table silver.erp_cust_az12;

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

    -- loading table: silver.erp_loc_a101

    truncate table silver.erp_loc_a101;

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

    -- loading table: silver.erp_px_cat_g1v2

    truncate table silver.erp_px_cat_g1v2;

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

END;
$$;

