-- ================================================
-- 07_intersection.sql
-- Question: What does the highest risk customer
-- look like when multiple risk factors combine?
-- ================================================


-- Step 1: Find churn rate where contract, internet
-- service and tenure combine together
-- This shows which combination is most dangerous

SELECT
    contract,
    internet_service,
    CASE WHEN tenure_months <= 10 THEN '0-10' ELSE '10+' END AS tenure_group,
    COUNT(*)                         AS total_customers,
    ROUND(AVG(churn_value) * 100, 2) AS churn_rate_pct
FROM raw_customers
GROUP BY contract, internet_service, tenure_group
ORDER BY churn_rate_pct DESC;

/*
Month-to-month + Fiber optic + 0-10 months = 71% churn rate
Month-to-month + DSL         + 0-10 months = 45% churn rate
Two year       + DSL         + 10+ months  =  2% churn rate

Same company. Same products. 71% vs 2% churn rate.
The combination of all three factors together is what
creates the extreme churn risk — not any one factor alone.
*/


-- ================================================

-- Step 2: How many active customers sit in the
-- worst combination right now and what is their
-- revenue at risk

SELECT
    COUNT(*)                        AS high_risk_active_customers,
    ROUND(SUM(monthly_charges), 2)  AS monthly_revenue_at_risk
FROM raw_customers
WHERE churn_value = 0
AND contract = 'Month-to-month'
AND internet_service = 'Fiber optic'
AND tenure_months <= 10;

/*
238 active customers in the most dangerous segment
$19,103 monthly revenue at risk from this group alone
These are the customers most likely to leave next
*/


-- ================================================

-- Step 3: Split those 238 customers by online security
-- Does having security add-on protect against churn
-- even inside the highest risk segment?

SELECT
    online_security,
    COUNT(*)                        AS customers,
    ROUND(SUM(monthly_charges), 2)  AS revenue_at_risk
FROM raw_customers
WHERE churn_value = 0
AND contract = 'Month-to-month'
AND internet_service = 'Fiber optic'
AND tenure_months <= 10
GROUP BY online_security
ORDER BY revenue_at_risk DESC;

/*
No security  → 204 customers → $16,266 at risk
Has security →  34 customers →  $2,836 at risk

204 vs 34 customers. Only difference is online security.
Customers without security are 6x more represented
in this already dangerous segment.

Business action:
Offer online security add-on to these 204 customers now.
A $10/month add-on protects $16,266 in monthly revenue.
Clearest ROI intervention in the entire project.
*/