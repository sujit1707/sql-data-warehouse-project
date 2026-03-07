-- Measure by Measure
-- examples: total products by sales range ; total customers by age
/* segment prodcuts into cost ranges and find how many products 
fall into each segment */

with product_segments as (
select product_key, product_name, cost,
case
when cost <100 then 'below 100'
when cost between 100 and 500 then '100 - 500'
when cost between 500 and 1000 then '500 - 1000'
else 'above 1000'
end as cost_range
from gold.dim_products
where cost is not null)

select count(product_key) as num_products, cost_range
from product_segments
group by cost_range
order by count(product_key) desc;

/* group customers into three segments based upon spending behaviour
VIP: atleast 12 months spending history and spent more than $ 5000
Regular: atleast 12 months of spending hsitory and spent less than or equal to $5000
New: less than 12 months spending history
*/

with customer_details as(
select c.customer_key , age(max(s.order_date),min(s.order_date)) as period,
sum(s.sales_amount) as total_spend,
case 
when
age(max(s.order_date),min(s.order_date)) >= interval '1 year' and 
sum(s.sales_amount) > 5000 then 'VIP'
when
age(max(s.order_date),min(s.order_date)) >= interval '1 year' and 
sum(s.sales_amount) <= 5000 then 'Regular'
when
age(max(s.order_date),min(s.order_date)) < interval '1 year'  then 'New'
end as customer_segments
from gold.fact_sales s
left join gold.dim_customers c
on s.customer_key=c.customer_key
group by c.customer_key)

select count(customer_key)as num_customers, customer_segments
from customer_details
group by customer_segments
order by num_customers desc;
