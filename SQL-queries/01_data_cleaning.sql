-- ============================================================
-- PROJECT: Smart Discounting — When Does It Work and When Does It Hurt?
-- FILE: 01_data_cleaning.sql
-- DESCRIPTION: Data cleaning steps for the Superstore dataset
-- Dataset: superstore-499203.superstore.sample_superstore_clean
-- ============================================================


-- STEP 1: Check total row count
-- Purpose: Understand the size of the raw dataset
SELECT COUNT(*) AS total_rows
FROM `superstore-499203.superstore.superstore-sample`;


-- STEP 2: Identify duplicate rows
-- Purpose: Find orders with the same Order ID and Product ID appearing more than once
SELECT `Order ID`, `Product ID`, COUNT(*) AS count
FROM `superstore-499203.superstore.superstore-sample`
GROUP BY `Order ID`, `Product ID`
HAVING COUNT(*) > 1;


-- STEP 3: Remove duplicates and create clean table
-- Purpose: Keep only the first occurrence of each Order ID + Product ID combination
CREATE TABLE `superstore-499203.superstore.sample_superstore_clean` AS
SELECT * EXCEPT(row_num)
FROM (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY `Order ID`, `Product ID`
      ORDER BY `Order ID`
    ) AS row_num
  FROM `superstore-499203.superstore.superstore-sample`
)
WHERE row_num = 1;


-- STEP 4: Check for NULL values in all columns
-- Purpose: Ensure no missing data exists across key fields
SELECT 
  COUNTIF(`Row ID` IS NULL) AS null_row_id,
  COUNTIF(`Order ID` IS NULL) AS null_order_id,
  COUNTIF(`Order Date` IS NULL) AS null_order_date,
  COUNTIF(`Ship Date` IS NULL) AS null_ship_date,
  COUNTIF(`Ship Mode` IS NULL) AS null_ship_mode,
  COUNTIF(`Customer ID` IS NULL) AS null_customer_id,
  COUNTIF(`Customer Name` IS NULL) AS null_customer_name,
  COUNTIF(Segment IS NULL) AS null_segment,
  COUNTIF(Country IS NULL) AS null_country,
  COUNTIF(City IS NULL) AS null_city,
  COUNTIF(State IS NULL) AS null_state,
  COUNTIF(`Postal Code` IS NULL) AS null_postal_code,
  COUNTIF(Region IS NULL) AS null_region,
  COUNTIF(`Product ID` IS NULL) AS null_product_id,
  COUNTIF(Category IS NULL) AS null_category,
  COUNTIF(`Sub-Category` IS NULL) AS null_sub_category,
  COUNTIF(`Product Name` IS NULL) AS null_product_name,
  COUNTIF(Sales IS NULL) AS null_sales,
  COUNTIF(Quantity IS NULL) AS null_quantity,
  COUNTIF(Discount IS NULL) AS null_discount,
  COUNTIF(Profit IS NULL) AS null_profit
FROM `superstore-499203.superstore.sample_superstore_clean`;


-- STEP 5: Validate categorical columns
-- Purpose: Check for unexpected or inconsistent category values
SELECT DISTINCT Category FROM `superstore-499203.superstore.sample_superstore_clean`;
SELECT DISTINCT Region FROM `superstore-499203.superstore.sample_superstore_clean`;
SELECT DISTINCT Segment FROM `superstore-499203.superstore.sample_superstore_clean`;
SELECT DISTINCT `Ship Mode` FROM `superstore-499203.superstore.sample_superstore_clean`;


-- STEP 6: Validate discount range
-- Purpose: Ensure discount values fall within expected 0-1 range
SELECT
  MIN(Discount) AS min_discount,
  MAX(Discount) AS max_discount
FROM `superstore-499203.superstore.sample_superstore_clean`;


-- STEP 7: Check for negative sales
-- Purpose: Negative sales values would indicate data errors
SELECT COUNT(*) AS negative_sales
FROM `superstore-499203.superstore.sample_superstore_clean`
WHERE Sales < 0;


-- STEP 8: Validate date range
-- Purpose: Confirm order dates are within expected time period
SELECT 
  MIN(`Order Date`) AS earliest_date,
  MAX(`Order Date`) AS latest_date
FROM `superstore-499203.superstore.sample_superstore_clean`;


-- STEP 9: Check for invalid ship dates
-- Purpose: Ship date should never be before order date
SELECT COUNT(*) AS invalid_dates
FROM `superstore-499203.superstore.sample_superstore_clean`
WHERE `Ship Date` < `Order Date`;


-- STEP 10: Fix date formats and update clean table
-- Purpose: Standardize Order Date and Ship Date to YYYY-MM-DD format
CREATE TEMP TABLE superstore_dates_fixed AS
SELECT
  * EXCEPT(`Order Date`, `Ship Date`),
  CASE
    WHEN LENGTH(`Order Date`) = 10 AND `Order Date` LIKE '____-__-__' THEN `Order Date`
    WHEN `Order Date` LIKE '%/%' THEN FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%m/%d/%Y', `Order Date`))
    WHEN `Order Date` LIKE '%-%' THEN FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%m-%d-%Y', `Order Date`))
    ELSE `Order Date`
  END AS `Order Date`,
  CASE
    WHEN LENGTH(`Ship Date`) = 10 AND `Ship Date` LIKE '____-__-__' THEN `Ship Date`
    WHEN `Ship Date` LIKE '%/%' THEN FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%m/%d/%Y', `Ship Date`))
    WHEN `Ship Date` LIKE '%-%' THEN FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%m-%d-%Y', `Ship Date`))
    ELSE `Ship Date`
  END AS `Ship Date`
FROM `superstore-499203.superstore.sample_superstore_clean`;

CREATE OR REPLACE TABLE `superstore-499203.superstore.sample_superstore_clean` AS
SELECT * FROM superstore_dates_fixed;


-- STEP 11: Final summary statistics
-- Purpose: Confirm clean dataset is ready for analysis
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT `Order ID`) AS unique_orders,
  COUNT(DISTINCT `Product ID`) AS unique_products,
  COUNT(DISTINCT `Customer ID`) AS unique_customers,
  ROUND(SUM(Sales), 2) AS total_sales,
  ROUND(SUM(Profit), 2) AS total_profit,
  ROUND(MIN(Discount), 4) AS min_discount,
  ROUND(MAX(Discount), 4) AS max_discount,
  COUNTIF(Profit < 0) AS loss_count,
  COUNTIF(Profit >= 0) AS profit_count
FROM `superstore-499203.superstore.sample_superstore_clean`;
