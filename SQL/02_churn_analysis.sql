-- =================================================================================
-- CUSTOMER CHURN PROFILING
-- =================================================================================


-- 1. WHAT IS THE GLOBAL CHURN RATE?
-- INSIGHT: Total Churn Rate is ~ 46%

SELECT
     ROUND(100 * AVG(is_churned),2) AS churn_percent
FROM `Global_Electronics_Retailer.dim_customers`
WHERE first_order_date IS NOT NULL;



-- 2. WHEN DO CUSTOMERS CHURN? 
-- INSIGHT: 73% of churned customers leave right after their 1st order

SELECT
     ROUND(100 * COUNTIF(total_orders = 1)/COUNT(*),2) AS churned_after_1st_order,
     ROUND(100 * COUNTIF(total_orders > 1)/COUNT(*),2) AS churned_later
FROM `Global_Electronics_Retailer.dim_customers`
WHERE is_churned=1;




-- 3. DEMOGRAPHICS: GENDER CHECK
-- INSIGHT: Churn is split almost exactly 50/50 between Male (~51%) and Female (~49%).Therefore, gender plays no role in customer Churn - product experience affects both equally.

SELECT
      ROUND(100 * COUNT(CASE WHEN gender='Male' Then 1 END)/COUNT(*),2) male_churn_pcnt,
      ROUND(100 * COUNT(CASE WHEN gender='Female' Then 1 END)/COUNT(*),2)female_churn_pcnt
FROM `Global_Electronics_Retailer.dim_customers`
WHERE is_churned=1;



-- 4. SPENDING SEGMENTATION: VOLUME OF CHURN BY SPENDING 
-- INSIGHT: Over 66% of all churned customers are Low Spenders and 1 out of 4 of High Spenders leave as well.Since most users leave after the first order, their total lifetime spend remains low.

-- Query Method:
-- 1. Use PERCENT_RANK() to dynamically assign a spending percentile to each customer.
-- 2. Segment customers based on their percentile:
--    - Top 20% (> 0.80) ➡️ VIP / High Spenders (Pareto Principle)
--    - Bottom 50% (<= 0.50) ➡️ Low Spenders
--    - Middle 30% (Between 0.50 and 0.80) ➡️ Medium Spenders
-- 3. Calculate the volume share of churned customers across these segments.

WITH customer_percentiles AS (
  SELECT 
    is_churned,
    total_spend_usd,
    PERCENT_RANK() OVER(ORDER BY total_spend_usd) AS spending_percentile
  FROM `Global_Electronics_Retailer.dim_customers`
  WHERE total_spend_usd > 0
)

SELECT 
  CASE 
    WHEN spending_percentile <= 0.50 THEN 'Low Spenders (Bottom 50%)'
    WHEN spending_percentile > 0.80 THEN 'VIP / High Spenders (Top 20%)'
    ELSE 'Medium Spenders (Middle 30%)'
  END AS wealth_segment,
  COUNT(*) AS total_buyers,
  ROUND(100 * COUNTIF(is_churned = 1) / COUNT(*), 2) AS group_churn_rate,
  ROUND(100 * COUNTIF(is_churned = 1) / SUM(COUNTIF(is_churned = 1)) OVER(), 2) AS share_of_total_churn
FROM customer_percentiles
GROUP BY wealth_segment;


-- 5. DEMOGRAPHICS: CHURN RATE BY AGE GROUP
-- INSIGHT: While The '14-18 (Teens)' group shows a catastrophic 100% churn rate, from age 19 to 61+,  churn stabilizes between 34%-36%. Seniors (61+) represent 35.27% of total churned customers due to being the largest customer age group.

WITH customer_ages AS 
(
  SELECT 
    is_churned,
    -- Calculates the customer age:
    -- If churned: Age at the exact point of churn (last_order_date) 
    -- If active: Age at the benchmark date (the maximum order date in the dataset)
    CASE 
      WHEN is_churned = 1 THEN EXTRACT(YEAR FROM last_order_date) - EXTRACT(YEAR FROM birthdate)
      ELSE EXTRACT(YEAR FROM MAX(last_order_date) OVER()) - EXTRACT(YEAR FROM birthdate)
    END AS customer_age
  FROM `Global_Electronics_Retailer.dim_customers`
  order by customer_age
),

age_segments AS (
  SELECT 
    is_churned,
    CASE 
      WHEN customer_age BETWEEN 14 AND 18 THEN '14-18 (Teens)'
      WHEN customer_age BETWEEN 19 AND 25 THEN '19-25 (Students)'
      WHEN customer_age BETWEEN 26 AND 40 THEN '26-40 (Adults)'
      WHEN customer_age BETWEEN 41 AND 60 THEN '41-60 (Mature Adults)'
      WHEN customer_age >= 61 THEN '61+ (Seniors)'
    END AS age_group
  FROM customer_ages
)

SELECT 
  age_group,
  COUNT(*) AS total_buyers, 
  ROUND(100 * COUNTIF(is_churned = 1) / COUNT(*), 2) AS group_churn_rate,
  ROUND(100 * COUNTIF(is_churned = 1) / SUM(COUNTIF(is_churned = 1)) OVER (), 2) AS share_of_total_churn
FROM age_segments
GROUP BY age_group
ORDER BY group_churn_rate DESC;


-- 6. GEOGRAPHICS: CHURN RATE BY COUNTRIES
-- INSIGHTS:
-- 1. AUSTRALIA: Highest churn rate (62.82%).
-- 2. USA: Lowest churn rate (39.87%) but causes 41.42% of all churn because it has the most customers (5706).

SELECT country,
       COUNTIF(total_orders >= 1) AS total_buyers,
       ROUND(100 * (COUNTIF(total_orders >= 1 AND is_churned = 1) / COUNTIF(total_orders >= 1)), 2) AS group_churn_rate,
       ROUND(100 * COUNTIF(is_churned = 1) / SUM(COUNTIF(is_churned = 1)) OVER(), 2) AS share_of_total_churn
FROM `Global_Electronics_Retailer.dim_customers`
group by country
order by group_churn_rate DESC;


-- 7. Does delivery time affect churn?
-- INSIGHT: No. Average delivery days are almost identical (~4.6 vs ~4.5 days). 
SELECT
      ROUND(AVG(CASE WHEN is_churned=1 THEN avg_delivery_days END), 2) AS churn_avg_delivery,
      ROUND(AVG(CASE WHEN is_churned = 0 THEN avg_delivery_days END), 2) AS active_avg_delivery,
      ROUND(AVG(avg_delivery_days), 2) AS avg_delivery
FROM `Global_Electronics_Retailer.dim_customers`;


-- 8. Did the company stop operating in certain countries (which might cause a churn spike)?
-- INSIGHT: No. The max order date in every country is close to the benchmark date. 
SELECT 
    country,
    MAX(last_order_date) AS latest_market_order_date
FROM `Global_Electronics_Retailer.dim_customers`
GROUP BY country;


-- =================================================================================
-- CUSTOMERS AT RISK
-- =================================================================================

-- 1. At-Risk Customer Benchmark
-- INSIGHT: 8.55% of total customers are classified as "at risk"
SELECT COUNT(DISTINCT customer_id) 
FROM `Global_Electronics_Retailer.dim_customers_at_risk`;

SELECT COUNT(DISTINCT customer_id) 
FROM `Global_Electronics_Retailer.dim_customers`
WHERE total_orders >=1;

 

-- 2. At-Risk Customers Breakdown 
-- INSIGHT: 13% are One-Time Buyers and 87% are Repeat Customers
SELECT 
  ROUND(100 * COUNTIF(total_orders = 1) / COUNT(*), 2) AS one_order,
  ROUND(100 * COUNTIF(total_orders > 1) / COUNT(*), 2) AS more_orders
FROM `Global_Electronics_Retailer.dim_customers_at_risk`;


-- 3. Spending Trend for At-Risk Repeat Customers
-- INSIGHT: 57% of repeat customers in risk showed a last order value that dropped below their personal historical Average Order Value (AOV)
WITH revenues AS (
  SELECT 
    r.customer_id,
    r.aov_usd,
    o.order_revenue_usd AS last_order_revenue
  FROM `Global_Electronics_Retailer.dim_customers_at_risk` r
  JOIN `Global_Electronics_Retailer.fct_orders` o
    ON r.customer_id = o.customer_id 
   AND r.total_orders > 1 
   AND r.last_order_date = o.order_date -- takes only the last order
)
SELECT 
  ROUND(100 * COUNTIF(aov_usd > last_order_revenue) / COUNT(*), 2) AS aov_higher_pcnt
FROM revenues;
