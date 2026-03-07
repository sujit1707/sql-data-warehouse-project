-- find difference between cuurent[Measure] and target[Measure].
/*Analyze the yearly performance of products by comparing their sales
to both the average sales per year performance of the product and the previous year's sales*/

with yearly_product_sales as ( 
select p.product_name, sum(s.sales_amount) as current_sales,
extract(year from s.order_date) as year
from gold.dim_products p
left join gold.fact_sales s
on p.product_key=s.product_key
where s.order_date is not null
group by year, p.product_name)

select year, product_name, current_sales,
avg(current_sales) over(partition by product_name) as product_avg_sales,
(current_sales::numeric-avg(current_sales) over(partition by product_name)) as diff_avg,
CASE
when (current_sales-avg(current_sales) over(partition by product_name)) > 0 then 'above avg'
when (current_sales-avg(current_sales) over(partition by product_name)) < 0 then 'below avg'
else 'avg'
end as avg_change,
lag(current_sales) over(partition by product_name order by year) as prev_year_sales,
current_sales - lag(current_sales) over(partition by product_name order by year) as diff_prev_year,
case 
when (current_sales - lag(current_sales) over(partition by product_name order by year))>0 then 'increasing'
when (current_sales-lag(current_sales) over(partition by product_name order by year))<0 then 'decreasing'
else 'no chnage'
end as prev_year_change
from yearly_product_sales 
order by product_name,year;