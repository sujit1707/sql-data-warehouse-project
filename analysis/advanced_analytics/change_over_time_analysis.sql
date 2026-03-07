-- analysis of [Measure] by [Date dimensions]
-- how measures change over time

-- analyze sales performance over time
select * from gold.fact_sales;

-- sales figures per year
select sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity,
extract(year from order_date) as order_year
from gold.fact_sales
where order_date is NOT NULL
group by order_year
order by order_year;

-- sales figures per month
select sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity,
extract(month from order_date) as order_month
from gold.fact_sales
where order_date is NOT NULL
group by order_month
order by order_month;

-- sales figures per month using date_trunc
select sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity,
date_trunc('month', order_date)::date as order_month
from gold.fact_sales
where order_date is NOT NULL
group by order_month
order by order_month;

