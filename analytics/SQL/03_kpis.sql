-- ================================================
-- 03_kpis.sql
-- Business KPIs for Telco Customer Churn Analysis
-- ================================================


-- KPI 1: Overall Churn Rate
-- How many out of every 100 customers are leaving?
-- Industry benchmark for telecom is below 10%

SELECT 
    ROUND(AVG(churn_value) * 100, 2) AS churn_rate_percentage
FROM raw_customers;

-- Result: 26.54% — more than 2x the industry benchmark


-- ================================================

-- KPI 2: Monthly Revenue Lost
-- Recurring monthly revenue gone because customers left

SELECT 
    ROUND(SUM(monthly_charges), 2) AS monthly_revenue_lost
FROM raw_customers
WHERE churn_value = 1;

-- Result: $139,130 lost every single month


-- ================================================

-- THRESHOLD DISCOVERY: Finding the At-Risk Churn Score Cutoff
-- Before calculating KPI 3 and KPI 5 we need to find
-- what churn_score value separates safe customers from at-risk ones
-- We do this by checking churn rate at each score range

SELECT 
    CASE
        WHEN churn_score <= 20  THEN '0-20'
        WHEN churn_score <= 40  THEN '21-40'
        WHEN churn_score <= 60  THEN '41-60'
        WHEN churn_score <= 80  THEN '61-80'
        WHEN churn_score <= 100 THEN '81-100'
    END AS score_bucket,
    COUNT(*)                    AS total_customers,
    SUM(churn_value)            AS churned_customers,
    ROUND(AVG(churn_value) * 100, 2) AS churn_rate_pct
FROM raw_customers
GROUP BY score_bucket
ORDER BY score_bucket;

-- Result:
-- 0-20   → 0%   churn rate
-- 21-40  → 0%   churn rate
-- 41-60  → 0%   churn rate
-- 61-80  → 32%  churn rate
-- 81-100 → 100% churn rate
--
-- Finding: Clean break at score 60
-- Below 60 = zero churn historically
-- Above 60 = churn begins
-- Threshold set at churn_score > 60 for all at-risk calculations


-- ================================================

-- KPI 3: Monthly Revenue at Risk
-- Revenue from active customers likely to leave soon
-- Uses threshold discovered above: churn_score > 60

SELECT 
    ROUND(SUM(monthly_charges), 2) AS monthly_revenue_at_risk,
    COUNT(*)                        AS high_risk_customer_count
FROM raw_customers
WHERE churn_value = 0
AND churn_score > 60;

-- Result: $104,070 at risk across 1,698 active customers


-- ================================================

-- KPI 4: Average CLTV — Churned vs Retained
-- Are we losing high value or low value customers?

SELECT
    CASE WHEN churn_value = 1 
        THEN 'Churned' 
        ELSE 'Retained' 
    END AS customer_status,
    ROUND(AVG(cltv), 2) AS average_cltv
FROM raw_customers
GROUP BY churn_value;

-- Result: Similar CLTV across both groups
-- We are losing customers across all value tiers equally
-- Churn is not concentrated in low value customers


-- ================================================

-- KPI 5: High Risk Active Customer Count
-- Active customers with churn score above discovered threshold
-- These are the customers the retention team acts on now

SELECT 
    COUNT(*) AS high_risk_active_customers
FROM raw_customers
WHERE churn_value = 0
AND churn_score > 60;

-- Result: 1,698 customers need immediate retention attention
-- Note: All customers with churn_score > 80 have already churned
-- By the time score reaches 80 it is too late to retain
-- Early intervention at score 61 is critical


-- ================================================

-- KPI 6: Average Tenure of Churned Customers
-- How long did customers stay before leaving?

SELECT 
    ROUND(AVG(tenure_months), 1) AS avg_tenure_before_churn
FROM raw_customers
WHERE churn_value = 1;

-- Result: 18 months average tenure before churning
-- Retention intervention should trigger around month 12-15
-- Before the average churn window opens