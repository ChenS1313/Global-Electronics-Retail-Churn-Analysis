# Global Electronics Retail Churn Analysis
A data analytics project using **BigQuery (SQL)** and **Tableau** to transform raw retail data into insights. The project focuses on identifying customer churn patterns, delivering actionable retention strategies, and building an interactive dashboard.

[In progress..]


## 📋 Table of Contents
* [🛠️ The Tech Stack](#-the-tech-stack)
* [🧹 Data Transformation & Cleansing](#-data-transformation--cleansing)
* [⏳ More sections in progress...]

* 
[In progress..]

## 🛠️ The Tech Stack
* **Data Warehouse:** Google BigQuery
* **Data Transformation & Analysis:** SQL (BigQuery SQL)

  [In progress..]



## 🧹 Data Transformation & Cleansing

Before diving into the Churn Analysis, a comprehensive Data Profiling and Cleansing process was performed using **Google BigQuery SQL**.                   The goal of this phase was to ensure data integrity, clean and structure the data, and build tables that eliminate the need for complex joins during analysis.

1. **Data Profiling & Quality Checks:** Checked the raw tables (`raw_customers`, `raw_sales`, `raw_products`) for missing primary keys, duplicates, and invalid business logic (e.g., negative quantities, delivery dates before order dates).

2. **Staging & Cleaning (`stg_customers`, `stg_sales`, `stg_products`):** Standardized all column names to `snake_case` and handled casing and leading/trailing whitespace (`TRIM`, `INITCAP`, `UPPER`).
  
3. **Marts (`dim_customers`, `dim_products`, `fct_order_items`, `fct_orders`):** Built the final analytical layer by aggregating and joining cleaned staging tables. This included creating core business metrics such as Recency, Frequency, and Monetary (RFM) values and essential behavioral dimensions (such as first and last order dates and average days between orders).


> **Note:** Since the dataset's timeline ends on February 20, 2021, this maximum `order_date` was used as a dynamic benchmark acting as "today."


  [In progress..]
