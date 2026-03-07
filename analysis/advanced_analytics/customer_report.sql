/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================


create view gold.report_customers as 
with base_query as (
-- 1) Base Query: Retrieves core columns from tables    
select s.order_number,
s.product_key,
s.order_date,
s.sales_amount,
s.quantity,
s.price,
c.customer_key,
c.customer_number,
concat(c.first_name,' ',c.last_name) as customer_name,
age(current_date, c.birthdate) as age
from gold.fact_sales s
left join gold.dim_customers c
on c.customer_key=s.customer_key
where s.order_date is not null),

customer_aggregation as (
--2) Customer Aggregations: summarizes key metrics at the customer level
select 
customer_key,
customer_number,
customer_name,
age,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_spend,
sum(quantity) as total_quantity,
count(distinct product_key) as total_product,
max(order_date) as last_order_date,
age(max(order_date),min(order_date)) as lifespan
from base_query
group by 
customer_key,
customer_number,
customer_name,
age)

select 
customer_key,
customer_number,
customer_name,
age,
CASE
when age < interval '20 years' then 'Under 20'
when age < interval '30 years' then '20-29'
when age < interval '40 years' then '30-39'
when age < interval '50 years' then '40-49'
else '50 and Above'
end as age_group,
case
when lifespan >= interval '1 year' and total_spend > 5000 then 'VIP'
when lifespan >= interval '1 year' and total_spend <= 5000 then 'Regular'
else 'New'
end as customer_segment,
-- compute time since last order
age(current_date, last_order_date) as recency,
total_orders,
total_spend,
total_quantity,
total_product,
last_order_date,
lifespan,
-- compute average order value of each customer
case when total_orders=0 then 0
else total_spend/total_orders 
end as avg_order_value,
-- compute average monthly spend
case when extract(year from lifespan) * 12 + extract(month from lifespan) =0 then total_spend
else round(total_spend/(extract(year from lifespan) * 12 + extract(month from lifespan)),2)
end as avg_monthly_spend
from customer_aggregation
