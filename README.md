# Global Electronics Retail Churn Analysis
A data analytics project using **BigQuery (SQL)** and **Tableau** to transform raw retail data into insights. The project focuses on identifying customer churn patterns, delivering actionable retention strategies, and building an interactive dashboard.

[In progress..]

## 🎯 The Business Problem

Acquiring new customers is significantly more expensive than retaining existing ones. 
The goal of this project is to analyze customer purchasing behavior, establish a robust behavioral churn definition, and translate data into actionable retention strategies.

### Key Questions Addressed:
* **Who is leaving?** Which customer demographics, regions, or segments carry the highest risk of churn?
* **What triggers churn?** What behavioral patterns (Recency, Frequency, Monetary) indicate an imminent drop-off?
* **How can we intervene?** What proactive steps can marketing and product teams take to retain high-value customers before they officially churn?

[In progress..]

## 📋 Table of Contents
* [🎯 The Business Problem](#-the-business-problem)
* [🛠️ The Tech Stack](#-the-tech-stack)
* [🧹 Data Transformation & Cleaning](#-data-transformation--cleansing)
* [⏳ More sections in progress...]


## 🛠️ The Tech Stack
* **Data Warehouse:** Google BigQuery
* **Data Transformation & Analysis:** SQL (BigQuery SQL)

  [In progress..]



## 🧹 Data Transformation & Cleaning

Before diving into the Churn Analysis, a comprehensive Data Profiling and Cleaning process was performed using **Google BigQuery SQL**.                   The goal of this phase was to ensure data integrity, clean and structure the data, and build tables that eliminate the need for complex joins during analysis.

1. **Data Profiling & Quality Checks:** Checked the raw tables (`raw_customers`, `raw_sales`, `raw_products`) for missing primary keys, duplicates, and invalid business logic (e.g., negative quantities, delivery dates before order dates).

2. **Staging & Cleaning** (`stg_customers`, `stg_sales`, `stg_products`): Standardized all column names to `snake_case` and handled casing and leading/trailing whitespace (`TRIM`, `INITCAP`, `UPPER`).
  
3. **Marts** (`dim_customers`, `dim_products`, `fct_order_items`, `fct_orders`): Built the final analytical layer by aggregating and joining cleaned staging tables. This included creating core business metrics such as Recency, Frequency, and Monetary (RFM) values and essential behavioral dimensions (e.g., first/last order dates and average days between orders).


> **Note:** Since the dataset timeline ends on February 20, 2021, this final date serves as a dynamic benchmark acting as "today" for all churn and recency analyses.


### Churn Logic & Methodology
Since retail customers do not have an explicit cancellation date or subscription end, defining churn requires a behavior-based threshold.
To accurately identify churned customers, the following logic was implemented in `dim_customers`:
* **Repeat Customers (>1 order):** 
A customer is classified as **churned** if the time since their last order (recency) exceeds **3x their personal average purchase frequency** (calculated based on their historical intervals between orders).

* **One-Time Buyers (1 order):** 
A customer is classified as **churned** if they haven't placed an order for **more than 365 days** since their last purchase.

> **Business Rationale:** A 365-day threshold was chosen to reflect the natural purchasing behavior of an electronics retailer, where customers buy infrequently (supported by the dataset's average customer interval of **411 days** between orders). This ensures we avoid prematurely flagging infrequent buyers as churned.

<br>


 * All SQL Transformation and Cleaning code can be found [here](./SQL/01_data_transformation.sql)



## 📊 Data Analysis & Insights

[In progress..]
