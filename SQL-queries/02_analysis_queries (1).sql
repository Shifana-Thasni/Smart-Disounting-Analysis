-- ============================================================
-- PROJECT: Smart Discounting — When Does It Work and When Does It Hurt?
-- FILE: 02_analysis_queries.sql
-- DESCRIPTION: Analysis queries used to build the Tableau dashboard
-- Dataset: superstore-499203.superstore.sample_superstore_clean
-- ============================================================


-- QUERY 1: Monthly Profit vs Discount
-- Purpose: Understand how profit and discount levels vary month by month
-- Used in: Monthly Profit vs Discount chart
SELECT 
  EXTRACT(MONTH FROM CAST(`Order Date` AS DATE)) AS month,
  FORMAT_DATE('%B', CAST(`Order Date` AS DATE)) AS month_name,
  ROUND(AVG(Discount), 2) AS avg_discount,
  ROUND(SUM(Profit), 2) AS total_profit,
  ROUND(SUM(Sales), 2) AS total_sales,
  ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS profit_margin_pct,
  COUNT(*) AS num_transactions,
  CASE 
    WHEN SUM(Profit) / SUM(Sales) > 0.2 THEN 'Highly Profitable'
    WHEN SUM(Profit) / SUM(Sales) > 0.1 THEN 'Profitable'
    WHEN SUM(Profit) / SUM(Sales) > 0 THEN 'Slightly Profitable'
    ELSE 'Unprofitable'
  END AS profit_status
FROM `superstore-499203.superstore.sample_superstore_clean`
GROUP BY month, month_name
ORDER BY month;


-- QUERY 2: Quarterly Profit vs Discount
-- Purpose: Identify which quarter drives the most profit and how discounts vary
-- Used in: Quarterly Profit vs Discount chart
SELECT 
  EXTRACT(QUARTER FROM CAST(`Order Date` AS DATE)) AS quarter,
  ROUND(AVG(Discount), 2) AS avg_discount,
  ROUND(SUM(Profit), 2) AS total_profit,
  ROUND(SUM(Sales), 2) AS total_sales,
  ROUND((SUM(Profit)/SUM(Sales))*100, 2) AS profit_margin_pct,
  COUNT(*) AS num_transactions,
  CASE 
    WHEN EXTRACT(QUARTER FROM CAST(`Order Date` AS DATE)) = 1 THEN 'Q1 Jan-Mar'
    WHEN EXTRACT(QUARTER FROM CAST(`Order Date` AS DATE)) = 2 THEN 'Q2 Apr-Jun'
    WHEN EXTRACT(QUARTER FROM CAST(`Order Date` AS DATE)) = 3 THEN 'Q3 Jul-Sep'
    ELSE 'Q4 Oct-Dec'
  END AS quarter_name
FROM `superstore-499203.superstore.sample_superstore_clean`
GROUP BY quarter, quarter_name
ORDER BY total_profit DESC;


-- QUERY 3: Category Profit vs Discount
-- Purpose: Compare how discount levels affect profit across product categories
-- Used in: Category Profit vs Discount chart
SELECT 
  Category,
  ROUND(AVG(Discount), 2) AS avg_discount,
  ROUND(SUM(Profit), 2) AS total_profit,
  ROUND(SUM(Sales), 2) AS total_sales,
  ROUND((SUM(Profit)/SUM(Sales))*100, 2) AS profit_margin_pct,
  COUNT(*) AS num_transactions,
  CASE 
    WHEN SUM(Profit) > 0 THEN 'Profitable'
    ELSE 'Loss'
  END AS profit_status
FROM `superstore-499203.superstore.sample_superstore_clean`
GROUP BY Category
ORDER BY total_profit DESC;


-- QUERY 4: Discount Threshold Analysis
-- Purpose: Find the optimal discount level — beyond what % does profit turn negative?
-- Used in: Discount Threshold chart (key insight: optimal discount ≤20%)
SELECT 
  CASE
    WHEN Discount = 0 THEN '1. No Discount (0%)'
    WHEN Discount > 0 AND Discount <= 0.1 THEN '2. Low (1-10%)'
    WHEN Discount > 0.1 AND Discount <= 0.2 THEN '3. Moderate (11-20%)'
    WHEN Discount > 0.2 AND Discount <= 0.3 THEN '4. High (21-30%)'
    WHEN Discount > 0.3 AND Discount <= 0.4 THEN '5. Very High (31-40%)'
    WHEN Discount > 0.4 AND Discount <= 0.5 THEN '6. Extreme (41-50%)'
    ELSE '7. Excessive (50%+)'
  END AS discount_bucket,
  ROUND(AVG(Discount), 2) AS avg_discount,
  ROUND(SUM(Profit), 2) AS total_profit,
  ROUND(SUM(Sales), 2) AS total_sales,
  ROUND((SUM(Profit)/SUM(Sales))*100, 2) AS profit_margin_pct,
  COUNT(*) AS num_transactions
FROM `superstore-499203.superstore.sample_superstore_clean`
GROUP BY discount_bucket
ORDER BY avg_discount;


-- QUERY 5: Regional Discount Effectiveness
-- Purpose: Identify which regions are most/least efficient with discounting
-- Used in: Regional Discount Effectiveness chart
SELECT 
  Region,
  ROUND(AVG(Discount), 2) AS avg_discount,
  ROUND(SUM(Profit), 2) AS total_profit,
  ROUND(SUM(Sales), 2) AS total_sales,
  ROUND((SUM(Profit)/SUM(Sales))*100, 2) AS profit_margin_pct,
  COUNT(*) AS num_transactions,
  CASE 
    WHEN SUM(Profit) > 0 THEN 'Profitable'
    ELSE 'Loss'
  END AS profit_status
FROM `superstore-499203.superstore.sample_superstore_clean`
GROUP BY Region
ORDER BY total_profit DESC;
