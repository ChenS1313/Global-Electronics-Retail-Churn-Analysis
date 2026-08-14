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

FROM `project-69dc4deb-819d-43d1-af9.Global_Electronics_Retailer.raw_customers`;


----------------------------------------------------------------------------------
-- 1.2 Staging Model Creation: stg_customers
----------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `project-69dc4deb-819d-43d1-af9.Global_Electronics_Retailer.stg_customers` AS
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
  FROM `project-69dc4deb-819d-43d1-af9.Global_Electronics_Retailer.raw_customers`
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

FROM `project-69dc4deb-819d-43d1-af9.Global_Electronics_Retailer.raw_sales`; 


----------------------------------------------------------------------------------
-- 2.2 Staging Model Creation: stg_sales
----------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `project-69dc4deb-819d-43d1-af9.Global_Electronics_Retailer.stg_sales` AS
(
SELECT
   -- Standardizing and rearranging the columns
    `Order Number` AS order_number,
    `Line Item` AS line_item,
     CustomerKey AS customer_id,
     StoreKey AS store_id,
     ProductKey AS product_id,
     Quantity AS quantity,
    `Order Date` AS order_date,
    `Delivery Date` AS delivery_date,
     UPPER(TRIM(`Currency Code`)) AS currency_code

FROM `project-69dc4deb-819d-43d1-af9.Global_Electronics_Retailer.raw_sales`
);



-- ===============================================================================
-- 3. MARTS LAYER ()
-- ===============================================================================
