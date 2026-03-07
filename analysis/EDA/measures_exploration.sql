select * from gold.fact_sales;
-- find total sales
select sum(sales_amount) as total_sales
from gold.fact_sales;

-- find how many items sold
select sum(quantity) as total_quantity
from gold.fact_sales 

-- find avg selling price 
select avg(price) as avg_price
from gold.fact_sales

-- find total number of orders 
select count(distinct order_number) as total_orders
from gold.fact_sales

-- find total number of products
select count(distinct product_number) as number_of_products , count(product_name)
from gold.dim_products

-- find total number of customers
select count(distinct customer_id) as number_of_customers
from gold.dim_customers;

-- find total number of customers that have placed an order
select count(distinct customer_key) as total_customers
from gold.fact_sales;

-- generate a report that shows all key metrics of the business

select 'total_sales' as measure_name , 
sum(sales_amount) as measure_value
from gold.fact_sales
union all
select 'total_quantity' as measure_name,
sum(quantity) as measure_value
from gold.fact_sales 
union all
select 'avg_price' as measure_name,
avg(price) as measure_value
from gold.fact_sales
union all
select 'total_orders' as measure_name,
count(distinct order_number) as measure_value
from gold.fact_sales
union all
select 'total_products' as measure_name,
count(distinct product_name) as measure_value
from gold.dim_products
union all
select 'number_of_customers' as measure_name,
count(distinct customer_id) as measure_value
from gold.dim_customers
union all
select 'total_customers' as measure_name,
count(distinct customer_key) as measure_value
from gold.fact_sales;