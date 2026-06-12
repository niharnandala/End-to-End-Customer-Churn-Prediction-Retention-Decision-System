-- ================================================
-- 04_contract.sql
-- Question: Which contract type is bleeding the most revenue?
-- ================================================


-- Step 1: Churn rate by contract type

SELECT 
    contract,
    ROUND(AVG(churn_value) * 100, 2) AS churn_rate_pct
FROM raw_customers
GROUP BY contract
ORDER BY churn_rate_pct DESC;

/*
Month-to-month  → 42.71%
One year        → 11.27%
Two year        →  2.83%
*/


-- ================================================

-- Step 2: Monthly revenue lost by contract type

SELECT 
    contract,
    ROUND(SUM(monthly_charges), 2) AS revenue_lost_monthly
FROM raw_customers
WHERE churn_value = 1
GROUP BY contract
ORDER BY revenue_lost_monthly DESC;

/*
Month-to-month  → $120,847
One year        →  $14,118
Two year        →   $4,165
*/


-- ================================================

-- Step 3: Revenue share of total loss by contract type
-- Window function calculates each contract's % of total loss
-- Shows which contract type is responsible for most damage

WITH contract_revenue AS (
    SELECT 
        contract,
        ROUND(SUM(monthly_charges), 2) AS revenue_lost
    FROM raw_customers
    WHERE churn_value = 1
    GROUP BY contract
)

SELECT
    contract,
    revenue_lost,
    ROUND(revenue_lost * 100.0 / SUM(revenue_lost) OVER(), 2) AS pct_of_total_loss
FROM contract_revenue
ORDER BY pct_of_total_loss DESC;

/*
Month-to-month  → $120,847  → 86.86% of total loss
One year        →  $14,118  → 10.15% of total loss
Two year        →   $4,165  →  2.99% of total loss

Key finding:
Month-to-month customers are 48% of total customers
but responsible for 87% of total revenue lost
The gap between customer share and revenue loss share
is where the retention budget should be focused
*/


-- ================================================

-- Step 4: Active customer revenue at risk by contract type
-- These customers have not churned yet
-- This is the recoverable revenue if action is taken now

SELECT 
    contract,
    COUNT(*)                        AS active_customers,
    ROUND(SUM(monthly_charges), 2)  AS revenue_at_risk
FROM raw_customers
WHERE churn_value = 0
GROUP BY contract
ORDER BY revenue_at_risk DESC;

/*
Month-to-month  → 2,220 customers → $136,447 at risk
Two year        → 1,647 customers →  $98,841 at risk
One year        → 1,307 customers →  $81,698 at risk

Action: Month-to-month active customers hold the highest
revenue at risk. Contract upgrade campaigns targeting
this group protect the most revenue per intervention.
*/