# SQL Data Warehouse & Analytics Project

## Project Overview

This project demonstrates the design and implementation of a modern SQL-based data warehouse along with analytical workflows for generating business insights.

The project follows the Medallion Architecture approach (Bronze → Silver → Gold), transforming raw transactional data into structured, analytics-ready datasets.

In addition to building the data warehouse, this project includes exploratory and advanced analytics queries that extract insights from the warehouse.

---

## Data Architecture

The warehouse is structured using three layers:

### Bronze Layer
- Raw data ingestion from CRM and ERP source systems
- Data loaded with minimal transformation
- Serves as the raw data foundation

### Silver Layer
- Data cleaning and transformation
- Data quality corrections
- Standardized schema for analytical processing

### Gold Layer
- Business-ready datasets
- Fact and dimension modeling
- Analytical views optimized for reporting

---

## Project Structure
data-warehouse-project
│
├── analysis
│   │
│   ├── docs
│   │   └── Project Roadmap.png
│   │
│   ├── EDA
│   │   ├── database_exploration.sql
│   │   ├── date_exploration.sql
│   │   ├── measures_exploration.sql
│   │   ├── dimensions_exploration.sql
│   │   ├── magnitude_exploration.sql
│   │   └── ranking_exploration.sql
│   │
│   └── advanced_analytics
│       ├── change_over_time_analysis.sql
│       ├── cumulative_analysis.sql
│       ├── part_to_whole_analysis.sql
│       ├── data_segmentation.sql
│       ├── performance_analysis.sql
│       ├── customers_report.sql
│       └── report_products.sql
│
├── scripts
│   │
│   ├── init_database.sql
│   │
│   ├── bronze
│   │   ├── bronze_ddl.sql
│   │   └── bronze_load.sql
│   │
│   ├── silver
│   │   ├── silver_ddl.sql
│   │   ├── silver_load.sql
│   │   └── exploratory
│   │       └── data_cleaning_tests.sql
│   │
│   └── gold
│       └── gold_ddl.sql
│
├── docs
│   ├── data_sources.drawio
│   ├── data_integration.drawio
│   ├── gold_layer_model.drawio
│   ├── naming_conventions.md
│   └── project_catalogue.md
│
├── dataset
│   │
│   ├── source_crm
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   │
│   └── source_erp
│       ├── cust_az12.csv
│       ├── loc_a101.csv
│       └── px_cat_g1v2.csv
│
├── README.md


---

## Data Sources

The project integrates data from two systems:

### CRM System
- Customer information
- Product information
- Sales transaction details

### ERP System
- Customer master data
- Location data
- Product category data

These datasets are loaded into the Bronze layer and progressively transformed into analytics-ready structures.

---

## Analytics

The project includes two analytics modules.

### Exploratory Data Analysis (EDA)

Explores the warehouse data using SQL queries including:

- Database exploration
- Date analysis
- Measure exploration
- Dimension exploration
- Magnitude analysis
- Ranking analysis

---

### Advanced Analytics

Advanced analytical queries including:

- Change-over-time analysis
- Cumulative analysis
- Part-to-whole analysis
- Data segmentation
- Performance analysis
- Customer reports
- Product reports

These queries demonstrate analytical SQL techniques used in business reporting.

---

## Technologies Used

- PostgreSQL
- SQL
- Draw.io (architecture diagrams)
- Git & GitHub
- Markdown

---

## Documentation

Additional documentation is available in the `docs` folder:

- Data source diagrams
- Data integration architecture
- Gold layer data modeling
- Naming conventions
- Project catalog

---

## Learning Objectives

This project demonstrates practical skills in:

- Data warehouse design
- SQL-based ETL pipelines
- Data modeling
- Analytical SQL
- Data quality handling
- Business reporting logic

---

## About Me

This project is part of my journey toward developing skills in:

- Data Engineering
- Data Science
- Machine Learning