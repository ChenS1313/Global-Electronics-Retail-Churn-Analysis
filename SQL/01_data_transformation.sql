-- ===============================================================================
-- 1. CUSTOMERS TABLE (raw_customers -> stg_customers)
-- ===============================================================================

----------------------------------------------------------------------------------
-- 1.1 Data Profiling & Quality Checks
----------------------------------------------------------------------------------

SELECT
-- Checking primary key
  COUNT(*) AS total_customers,
  COUNT(DISTINCT CustomerKey) AS unique_customer_keys,
  
-- Checking nulls on critical colums for analysis
  COUNTIF(CustomerKey IS NULL) AS null_keys,
  COUNTIF(Gender IS NULL) AS missing_gender,
  COUNTIF(City IS NULL) AS missing_cities,
  COUNTIF(Country IS NULL) AS missing_countries,
  COUNTIF(Continent IS NULL) AS missing_continents,
  COUNTIF(Birthday IS NULL) AS missing_birthdays,

-- Checking business logic
  COUNTIF(Birthday > CURRENT_DATE()) AS future_birthdays,
  COUNTIF(DATE_DIFF(CURRENT_DATE(), Birthday, YEAR) < 13) AS under_13_years_old, -- too young
  COUNTIF(DATE_DIFF(CURRENT_DATE(), Birthday, YEAR) > 100) AS over_100_years_old -- too old

FROM `Global_Electronics_Retailer.raw_customers`;

----------------------------------------------------------------------------------
-- 1.2 Staging Model Creation: stg_customers
----------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `Global_Electronics_Retailer.stg_customers` AS
(
 SELECT
-- Standardizing and rearranging the columns
    CustomerKey AS customer_id,
    INITCAP(TRIM(Name)) AS name,
    INITCAP(TRIM(Gender)) AS gender,
    Birthday AS birthdate,
    INITCAP(TRIM(City)) AS city,
    INITCAP(TRIM(State)) AS state,
    TRIM(`Zip Code`) AS zip_code,
    INITCAP(TRIM(Country)) AS country,
    INITCAP(TRIM(Continent)) AS continent
  FROM `Global_Electronics_Retailer.raw_customers`
);


-- ===============================================================================
-- 2. SALES TABLE (raw_sales -> stg_sales)
-- ===============================================================================

----------------------------------------------------------------------------------
-- 2.1 Data Profiling & Quality Checks
----------------------------------------------------------------------------------

SELECT
  COUNT(*) AS total_rows,
  
  -- Checking nulls on critical colums for analysis
  COUNTIF(`Order Number` IS NULL) AS null_order_numbers,
  COUNTIF(`Line Item` IS NULL) AS null_line_items,
  COUNTIF(CustomerKey IS NULL) AS null_customer_keys,
  COUNTIF(StoreKey IS NULL) AS null_store_keys,
  COUNTIF(ProductKey IS NULL) AS null_product_keys,
  COUNTIF(`Order Date` IS NULL) AS null_order_dates,
  
  -- Checking business logic
  COUNTIF(Quantity IS NULL OR Quantity <= 0) AS invalid_quantity,
  COUNTIF(`Delivery Date` < `Order Date`) AS delivery_before_order

FROM `Global_Electronics_Retailer.raw_sales`; 


----------------------------------------------------------------------------------
-- 2.2 Staging Model Creation: stg_sales
----------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `Global_Electronics_Retailer.stg_order_items` AS
(
  SELECT
    -- Standardizing and rearranging the columns
      `Order Number` AS order_id,
      `Line Item` AS line_item,
      CustomerKey AS customer_id,
      StoreKey AS store_id,
      ProductKey AS product_id,
      Quantity AS quantity,
      `Order Date` AS order_date,
      `Delivery Date` AS delivery_date,
      UPPER(TRIM(`Currency Code`)) AS currency_code

  FROM `Global_Electronics_Retailer.raw_sales`
);


-- ===============================================================================
-- 3. PRODUCTS TABLE (raw_products -> stg_products)
-- ===============================================================================

----------------------------------------------------------------------------------
-- 3.1 Data Profiling & Quality Checks
----------------------------------------------------------------------------------

SELECT
  COUNT(*) AS total_rows,
  
  -- Checking nulls on critical columns for analysis
  COUNTIF(ProductKey IS NULL) AS null_product_keys,
  COUNTIF(`Product Name` IS NULL) AS null_product_names,
  COUNTIF(Brand IS NULL) AS null_brands,
  COUNTIF(Color IS NULL) AS null_colors,
  COUNTIF(CategoryKey IS NULL) AS null_category_keys,
  COUNTIF(Category IS NULL) AS null_categories,
  COUNTIF(SubcategoryKey IS NULL) AS null_subcategory_keys,
  COUNTIF(Subcategory IS NULL) AS null_subcategories,
  
  -- Checking business logic
  COUNTIF(`Unit Cost USD` IS NULL OR `Unit Cost USD` <= 0) AS invalid_unit_cost,
  COUNTIF(`Unit Price USD` IS NULL OR `Unit Price USD` <= 0) AS invalid_unit_price,
  COUNTIF(`Unit Cost USD` > `Unit Price USD`) AS negative_margin_products

FROM `Global_Electronics_Retailer.raw_products`;


----------------------------------------------------------------------------------
-- 3.2 Staging Model Creation: stg_products
----------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `Global_Electronics_Retailer.stg_products` AS
(
  SELECT
  -- Standardizing and rearranging the columns
      ProductKey AS product_id,
      INITCAP(TRIM(`Product Name`)) AS product_name,
      INITCAP(TRIM(Subcategory)) AS subcategory,
      SubcategoryKey AS subcategory_id,
      INITCAP(TRIM(Category)) AS category,
      CategoryKey AS category_id,
      INITCAP(TRIM(Brand)) AS brand,
      INITCAP(TRIM(Color)) AS color,
      `Unit Cost USD` AS unit_cost_usd,
      `Unit Price USD` AS unit_price_usd

  FROM `Global_Electronics_Retailer.raw_products`
);


-- ===============================================================================
-- 4. MARTS LAYER ()
-- ===============================================================================

----------------------------------------------------------------------------------
-- 4.1 Marts Layer: Fact Table - fct_order_items
----------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `Global_Electronics_Retailer.fct_order_items` AS
(
  SELECT
  -- Identifiers
      s.order_id,
      s.line_item,
      s.customer_id,
      s.store_id,
      s.product_id,
      
  -- Dates & Currency
      s.order_date,
      s.delivery_date,
      s.currency_code,
      
  -- Item Unit Metrics
      s.quantity,
      p.unit_price_usd,
      
  -- Line Item Revenue 
      ROUND(s.quantity * p.unit_price_usd, 2) AS total_revenue_usd

  FROM `Global_Electronics_Retailer.stg_order_items` AS s

  LEFT JOIN `Global_Electronics_Retailer.stg_products` AS p
      ON s.product_id = p.product_id
);


----------------------------------------------------------------------------------
-- 4.2 Marts Layer: Fact Table - fct_orders
----------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `Global_Electronics_Retailer.fct_orders` AS
(
  SELECT
      order_id,
      customer_id,
      order_date,
      delivery_date,
      
    -- Order-Level Metrics
      SUM(quantity) AS total_items,
      ROUND(SUM(total_revenue_usd), 2) AS order_revenue_usd,
      DATE_DIFF(delivery_date, order_date, DAY) AS delivery_days

  FROM `Global_Electronics_Retailer.fct_order_items`
  GROUP BY 
      order_id,
      customer_id,
      order_date,
      delivery_date
);

----------------------------------------------------------------------------------
-- 4.3 Marts Layer: Dim Table - dim_products
----------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `Global_Electronics_Retailer.dim_products` AS
(
  SELECT 
      product_id,
      product_name,
      subcategory,
      subcategory_id,
      category,
      category_id,
      brand,
      color,
      unit_cost_usd,
      unit_price_usd

from `Global_Electronics_Retailer.stg_products`

);

----------------------------------------------------------------------------------
-- 4.4 Marts Layer: Dim Table - dim_customers
----------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `Global_Electronics_Retailer.dim_customers` AS
(
  WITH customer_summary AS (
      SELECT 
          customer_id,
          MIN(order_date) AS first_order_date,
          MAX(order_date) AS last_order_date,
          COUNT(order_id) AS total_orders,
          SUM(total_items) AS total_items_purchased,
          ROUND(SUM(order_revenue_usd),2) AS total_spend_usd,
          ROUND(AVG(order_revenue_usd), 2) AS aov_usd,
          ROUND(AVG(delivery_days), 1) AS avg_delivery_days,

      -- Calculates the average time between orders for customers with more than one order
          CASE 
              WHEN COUNT(order_id) > 1 
              THEN ROUND(DATE_DIFF(MAX(order_date), MIN(order_date), DAY) / (COUNT(order_id) - 1),0)
              ELSE NULL 
          END AS avg_days_between_orders,

       -- Takes the dataset's max order_date (benchmark acting as 'today') and calculates the days difference to the customer's last order
          DATE_DIFF(MAX(MAX(order_date)) OVER(), MAX(order_date), DAY) AS recency_days

      FROM `Global_Electronics_Retailer.fct_orders`
      GROUP BY customer_id
  )
  SELECT 
      c.customer_id,
      c.name,
      c.gender,
      c.birthdate,
      c.city,
      c.state,
      c.zip_code,
      c.country,
      c.continent,
      s.first_order_date, 
      s.last_order_date,

   -- Null handling for customers without an order
      COALESCE(s.total_orders, 0) AS total_orders,
      COALESCE(s.total_items_purchased, 0) AS total_items_purchased,
      COALESCE(s.total_spend_usd, 0) AS total_spend_usd,

      s.aov_usd,
      s.avg_delivery_days,
      s.avg_days_between_orders,
      s.recency_days,

    /* Churn Logic: 
      - For single-order customers: churned if recency > 365 days
      - For repeat customers: churned if recency > 3 * average days between orders
     */
      CASE
          WHEN s.total_orders = 1 AND s.recency_days > 365 THEN 1
          WHEN s.total_orders > 1 AND s.recency_days > (3 * s.avg_days_between_orders) THEN 1
          ELSE 0 
      END AS is_churned

  FROM `Global_Electronics_Retailer.stg_customers` AS c
  LEFT JOIN customer_summary AS s
      ON c.customer_id = s.customer_id

);



