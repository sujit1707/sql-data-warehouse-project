-- what schemas exists 
SELECT schema_name
FROM information_schema.schemata
ORDER BY schema_name;

-- what tables and views exists
SELECT table_schema,
       table_name,
       table_type
FROM information_schema.tables
WHERE table_schema in ('bronze','silver','gold')
ORDER BY table_schema, table_name;

-- column information of gold schema 
SELECT table_schema,
       table_name,
       column_name,
       data_type,
       is_nullable
FROM information_schema.columns
WHERE table_schema = 'gold'
ORDER BY table_name, ordinal_position;

-- check size of tables
select count(*) from gold.dim_customers;
select count(*) from gold.dim_products;
select count(*) from gold.fact_sales;