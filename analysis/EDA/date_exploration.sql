-- max and min order_date from gold.fact_sales
select max(order_date) as max_order_date,
min(order_date ) as min_order_date,
extract(age from age(max(order_date),min(order_date))) as order_range_years
from gold.fact_sales

-- find youngest and oldest customers
select max(birthdate) as youngest_birthdate,
age(current_date,(max(birthdate))) as youngest_age,
min(birthdate) as oldest_birthdate,
age(current_date, min(birthdate)) as oldest_age
from gold.dim_customers;