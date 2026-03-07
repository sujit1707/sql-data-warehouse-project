/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
DROP VIEW IF EXISTS gold.report_products;
CREATE VIEW gold.report_products AS

WITH base_query AS (
--1) Base Query: Retrieves core columns from fact_sales and dim_products
    SELECT
    s.order_number,
    s.order_date,
    s.customer_key,
    s.sales_amount,
    s.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL  -- only consider valid sales dates
        ),

    product_aggregations AS (
    --2) Product Aggregations: Summarizes key metrics at the product level
    SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    AGE(MAX(order_date), MIN(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND((SUM(sales_amount)::numeric / NULLIF(SUM(quantity), 0)),1) AS avg_selling_price
    FROM base_query
    GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
    )

    --3) Final Query: Combines all product results into one output

    SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    AGE(CURRENT_DATE,last_sale_date) AS recency,
    CASE
    WHEN total_sales > 50000 THEN 'High-Performer'
    WHEN total_sales >= 10000 THEN 'Mid-Range'
    ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- Average Order Revenue (AOR)
    CASE 
    WHEN total_orders = 0 THEN 0
    ELSE total_sales::numeric / total_orders
    END AS avg_order_revenue,
    -- Average Monthly Revenue
    CASE
    WHEN (EXTRACT(YEAR FROM lifespan)*12 + EXTRACT(MONTH FROM lifespan)) = 0 THEN total_sales
    ELSE ROUND(total_sales/(EXTRACT(YEAR FROM lifespan)*12 + EXTRACT(MONTH FROM lifespan)),2) 
    END AS avg_monthly_revenue

    FROM product_aggregations ;


