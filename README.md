# Global Electronics Retail Churn Analysis
A data analytics project using **BigQuery (SQL)** and **Tableau** to transform raw retail data into insights. The project focuses on identifying customer churn patterns, delivering actionable retention strategies, and building an interactive dashboard.

[In progress..]

## 🎯 The Business Problem

Acquiring new customers is significantly more expensive than retaining existing ones. 
The goal of this project is to analyze customer purchasing behavior, establish a robust behavioral churn definition, and translate data into actionable retention strategies.

### Key Questions Addressed:
* **Who is leaving?** Which customer demographics, regions, or segments carry the highest risk of churn?
* **What triggers churn?** What behavioral patterns (Recency, Frequency, Monetary) indicate an imminent drop-off?
* **How can we intervene?** What proactive steps can marketing and product teams take to retain customers before they officially churn?


## 📋 Table of Contents
* [🛠️ The Tech Stack](#-the-tech-stack)
* [🧹 Data Transformation & Cleaning](#-data-transformation--cleansing)
* [🔍 Data Analysis & Insights](#-data-analysis--insights)
* [💡 Strategic Recommendations](#strategic-recommendations)
* [📊 Interactive Dashboard](#-interactive-dashboard).
  
 [⏳ More sections in progress...]

## 🛠️ The Tech Stack
* **Data Warehouse:** Google BigQuery
* **Data Transformation & Analysis:** SQL

  [In progress..]



## 🧹 Data Transformation & Cleaning

Before diving into the Churn Analysis, a comprehensive Data Profiling and Cleaning process was performed using **SQL**.The goal of this phase was to ensure data integrity, clean and structure the data, and build tables that eliminate the need for complex joins during analysis.

1. **Data Profiling & Quality Checks:** Checked the raw tables (`raw_customers`, `raw_sales`, `raw_products`) for missing primary keys, duplicates, and invalid business logic (e.g., negative quantities, delivery dates before order dates).

2. **Staging & Cleaning** (`stg_customers`, `stg_sales`, `stg_products`): Standardized all column names to `snake_case` and handled casing and leading/trailing whitespace (`TRIM`, `INITCAP`, `UPPER`).
  
3. **Marts** (`dim_customers`, `dim_products`, `fct_order_items`, `fct_orders`,`dim_customers_at risk`): Built the final analytical layer by aggregating and joining cleaned staging tables. This included creating core business metrics such as Recency, Frequency, and Monetary (RFM) values and essential behavioral dimensions (e.g., first/last order dates and average days between orders).


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



## 🔍 Data Analysis & Insights

> ### Global Churn Rate: `46.2%`
> **Nearly 1 out of every 2 customers ends up churning**

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
* **Young Users:** Teens (14-18) show a catastrophic **`100% `churn rate**. While they represent a smaller portion of our customers, the company is completely failing to retain younger audiences.
* **Older Users (Mature Adults & Seniors):** On the other hand, Mature Adults (41-60) and Seniors (61+) present the lowest churn rates (**`35%`** and **`34%`** respectively). They represent our largest customer groups and also our most loyal.


### 5. Geographic Churn
* **AUSTRALIA:**  This country has the highest churn rate (63%), pointing to localization issues such as shipping difficulties and a lack of localized payment methods.
* **USA:** Has the lowest churn rate (**`40%`**), but accounts for a massive **`41%` of total company churn** due to its huge customer volume.


### 6. Refuting Alternative Hypotheses
* **Delivery Times hypothesis:**  Average delivery times for churned vs. active customers are nearly identical (**`4.6` vs. `4.5` days**). This proves logistics is not the driver for churning.

* **Market Operation hypothesis:** Maximum order dates across all countries align closely with the benchmark date, confirming active markets. This proves the company is available across all markets and that customer churn is driven by active abandonment rather than lack of service availability.

<br>


> ### At-Risk Customers: `8.56%`

---

* **One-Time Buyers (13%):** 
Positioned around our 331-day median interval between orders (recency of 300–365 days).

* **Repeat Customers (87%):** 
Buyers with multiple orders whose recency falls between **$2\times$ and $3\times$ their personal average purchase frequency**. Among them:
    * **Low-Basket Segment (57%):** Experienced a recent order value **below** their personal historical AOV, signaling that they are exploring alternatives or slowly losing interest.
    * **High-Basket Segment (43%):** Maintained a recent order value **at or above** their personal historical AOV, but suddenly broke their natural purchasing cadence.

<br>

* All SQL Churn Analysis code can be found [here](./SQL/02_churn_analysis.sql)


## 💡 Strategic Recommendations 

* Deploy a targeted **post-churn** feedback survey identifying operational friction or expectation gaps in order to diagnose why 73% of customers vanished **after their first purchase**. Based on these insights, take immediate actions in order to optimize the experience and prevent future churn.


* **Gender** plays no role in customer retention. The product and service experience affects both groups equally, meaning retention strategies should remain gender-neutral.


* Building an automated alert system triggered when **High Spenders** deviate from their standard purchasing frequency. Once a slowdown is detected, the system automatically sends a targeted incentive or offer for their next purchase, preventing them from churning to competitors.


* Redirect marketing and product retention budgets entirely toward **Mature Adults and Seniors**. Since they form our largest and most loyal customer groups, protecting them is critical for revenue stability. Even a small percentage drop in churn saves significant volume. 


* Prioritize the **US market**: due to its high customer volume, even a moderate churn percentage translates into significant revenue loss, making it our highest-leverage area for **retention efforts**.



### At-Risk Customers:

* **One-Time Buyers :** 
 To effectively engage and secure their second purchase, a personalized Cross-Sell approach is highly recommended. By offering specific, complementary accessories tailored directly to their first-order items, we can drive the second purchase right when their buying intent peaks.

* **Repeat Customers:** 
  * **Low-Basket Segment:** Deploy targeted win-back campaigns and incentivized feedback surveys to diagnose operational friction or expectation gaps before they leave.
  * **High-Basket Segment:** Deploy a targeted at-risk survey to uncover friction or delays. If issues are detected, automatically trigger compensation vouchers and priority support to secure retention and protect revenue.


## 📊 Interactive Dashboard

Since Tableau Public does not support a direct connection to Google BigQuery, the processed and cleaned Data Marts were exported into a single multi-sheet Excel workbook. This Excel file was then loaded into Tableau Public to build the interactive dashboard.
