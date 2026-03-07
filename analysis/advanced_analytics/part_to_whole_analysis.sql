-- (measure/total measure)*100 by [dimension]
-- (sales/total sales)*100 by category

-- which categories contribute the most to overall sales
select category, total_sales, 
sum(total_sales) over() as overall_sales,
round((total_sales::numeric/sum(total_sales) over())*100,2) as sales_percentage
from(
select category, sum(sales_amount) as total_sales
from gold.dim_products p
left join gold.fact_sales s 
on p.product_key = s.product_key
group by category) t 
order by total_sales;


