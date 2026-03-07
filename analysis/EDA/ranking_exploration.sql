-- rank dimensions by measures 
--to identify top or bottom performers 

-- what are the 5 best-performing products in terms of sales ?
select p.product_name, sum(s.sales_amount) as total_revenue
from gold.fact_sales s 
left join gold.dim_products p
on s.product_key = p.product_key
group by p.product_name
order by total_revenue desc
limit 5;

-- what are the 5 worst-performing products in terms of sales ?
select p.product_name, sum(s.sales_amount) as total_revenue
from gold.fact_sales s 
left join gold.dim_products p
on s.product_key = p.product_key
group by p.product_name
order by total_revenue 
limit 5;

-- find top 10 customers who have generated highest revenue
select * 
from(
select c.customer_key, c.first_name,c.last_name,sum(s.sales_amount) as total_revenue,
dense_rank() over(order by sum(s.sales_amount) desc) as rank_customers
from gold.fact_sales s 
left join gold.dim_customers c
on s.customer_key=c.customer_key
group by c.customer_key, c.first_name, c.last_name 
order by total_revenue desc) 
where rank_customers <11;