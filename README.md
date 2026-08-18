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
* [📊 Data Analysis & Insights](#-data-analysis--insights)
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

> **Business Rationale:** A 365-day threshold was chosen to reflect the natural purchasing behavior of an electronics retailer, where customers buy infrequently (supported by the dataset's average customer interval of **411 days** between orders and a median of **331 days**). This ensures we avoid prematurely flagging infrequent buyers as churned.



### At-Risk Logic & Methodology
To identify customers who are showing signs of potential churn before they officially cross the churn threshold, a behavioral early-warning logic was implemented in a dedicated mart table (`dim_at_risk_customers`).

* **Repeat Customers (>1 order):** 
A customer is classified as **at-risk** if the time since their last order (recency) exceeds **2x their personal average purchase frequency** (and remains under the churn threshold of 3x).

* **One-Time Buyers (1 order):** 
A customer is classified as **at-risk** if they haven't placed an order for **300 to 365 days** since their purchase.

> **Business Rationale:** The median inter-purchase interval in the dataset is 331 days. A lower threshold of 300 days was chosen to provide a strategic safety margin for one-time buyers, capturing them just before they hit the 365-day churn mark.
<br>


 * All SQL Transformation and Cleaning code can be found [here](./SQL/01_data_transformation.sql)



## 📊 Data Analysis & Insights

> ### Global Churn Rate: `36.21%`
> **More than 1 out of every 3 customers ends up churning**

---

### 1. Behavioral Churn
* **First-Order Churn:** **`73%`** of all churned customers leave immediately after order #1. 
  <br> This indicates a negative customer experience occurring in the first order (such as damaged product, or a mismatch between marketing promises and product reality).

### 2. Demographic Churn: Gender 
 * **Churn Equality:** Churn is split almost exactly **50/50** between Male (**`51%`**) and Female (**`49%`**) customers.


### 3. Wealth Segmentation

* **Low Spenders (Bottom 50%):** Show a massive **`61%` churn rate**, accounting for **`66%` of total churned volume**. This correlates directly with our first-order drop-off metric. These "Low Spenders" are essentially the one-time buyers who left immediately after their initial purchase.
* **VIP / High Spenders (Top 20%):** In contrast, high spenders exhibit strong stability with a low churn rate of **`25%`**, contributing merely **`11%` of total churn**. They form our most secure and valuable revenue anchor.



### 4. Demographic Churn: Age Group
* **Young Users (Teens & Students):** Teens (14-18) show a catastrophic **`100% `churn rate**, closely followed by Students (19-25) at **`75%`**. While they represent a smaller portion of our customers, the company is completely failing to retain younger audiences.
* **Older Users (Mature Adults & Seniors):** On the other hand, Mature Adults (41-60) and Seniors (61+) present the lowest churn rates (**`35%`** and **`34%`** respectively). They represent our largest customer groups and also our most loyal.


### 5. Geographic Churn
* **ITALY:** Although representing our smallest market by volume, it derives the highest churn rate (**`44%`**), notably higher than other European markets (**`38%–39%`**).<br> This points to localization problems, such as lack of native language support or localized payment methods.
* **USA:** Has the lowest churn rate (**`33%`**), but accounts for a massive **`41%` of total company churn** due to its huge customer volume.


### 6. Refuting Alternative Hypotheses
**Delivery Times hypothesis:**  Average delivery times for churned vs. active customers are nearly identical (**`4.6` vs. `4.5` days**). This proves logistics is not the driver for churning.

**Market Operation hypothesis:** Maximum order dates across all countries align closely with the benchmark date, confirming active markets. This proves the company is available across all markets and that customer churn is driven by active abandonment rather than lack of service availability.

[In progress..]
