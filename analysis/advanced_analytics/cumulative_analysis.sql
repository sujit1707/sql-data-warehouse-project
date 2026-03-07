-- aggregate data progressively over time
-- aggregate [cumulative measure] over [time dimension]

-- calculate total sales per month and the running total sales over time
select order_month, total_sales,
sum(total_sales) over(order by order_month) as monthly_cumulative_sales
from
(select sum(sales_amount) as total_sales,
date_trunc('month',order_date)::date as order_month
from gold.fact_sales
where order_date is not NULL
group by order_month)t
order by order_month;

-- calculate running total sales per month for each year
select order_month, total_sales,
sum(total_sales) over(partition by extract(year from order_month) order by order_month) as monthly_cumulative_sales_of_year
from
(select sum(sales_amount) as total_sales,
date_trunc('month',order_date)::date as order_month
from gold.fact_sales
where order_date is not NULL
group by order_month)t
order by order_month;

--  moving average price
select order_month, avg_price,
avg(avg_price) over(order by order_month) as moving_avg_price
from
(select avg(price) as avg_price,
date_trunc('month',order_date)::date as order_month
from gold.fact_sales
where order_date is not null
group by order_month) t 
order by order_month;

-- calculate month on month %age growth in sales
with monthly_sales as (
select sum(sales_amount) as total_sales,
date_trunc('month',order_date)::date as order_month
from gold.fact_sales
where order_date is not NULL
group by order_month),

previous as (
    select order_month,total_sales,
    lag(total_sales) over(order by order_month) as prev_month_sales
    from monthly_sales
)

select total_sales, order_month, 
prev_month_sales, round((total_sales-prev_month_sales)::numeric/nullif(prev_month_sales,0)*100,2) as percent_growth
from previous
order by order_month;

-- year on year sales analysis
with monthly_sales as (
select sum(sales_amount) as total_sales,
date_trunc('month',order_date)::date as order_month
from gold.fact_sales
where order_date is not NULL
group by order_month),

previous as (
    select order_month,total_sales,
    lag(total_sales,12) over(order by order_month) as prev_year_sales -- compare months between years
    from monthly_sales
)

select order_month, total_sales, 
prev_year_sales, round((total_sales-prev_year_sales)::numeric/nullif(prev_year_sales,0)*100,2) as percent_growth
from previous
order by order_month;