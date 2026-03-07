
select * from gold.dim_customers;

-- check distinct countries of customers
select distinct country 
from gold.dim_customers;

-- check all the categories of products 
select distinct category
from gold.dim_products;

-- check subcategories of products 
select distinct category , subcategory
from gold.dim_products;

-- check distinct products with category and subcategory
select distinct category, subcategory , product_name
from gold.dim_products
order by category, subcategory;