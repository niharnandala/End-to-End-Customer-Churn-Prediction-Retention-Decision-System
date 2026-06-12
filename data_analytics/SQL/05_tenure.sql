-- ================================================
-- 05_tenure.sql
-- Question: At what point in the customer lifetime
-- is revenue bleeding the most?
-- ================================================


-- Step 1: Churn rate and revenue by tenure bucket
-- Segments customers into 10-month groups
-- Shows where churn is concentrated in customer lifetime

WITH tenure_revenue AS (
    SELECT
        CASE
            WHEN tenure_months <= 10 THEN '0-10'
            WHEN tenure_months <= 20 THEN '11-20'
            WHEN tenure_months <= 30 THEN '21-30'
            WHEN tenure_months <= 40 THEN '31-40'
            WHEN tenure_months <= 50 THEN '41-50'
            WHEN tenure_months <= 60 THEN '51-60'
            WHEN tenure_months <= 70 THEN '61-70'
            ELSE '71-72'
        END AS tenure_bucket,
        COUNT(*)                                                                 AS total_customers,
        SUM(churn_value)                                                         AS churned,
        COUNT(*) - SUM(churn_value)                                              AS retained,
        ROUND(AVG(churn_value) * 100, 2)                                         AS churn_rate_pct,
        ROUND(SUM(CASE WHEN churn_value = 1 THEN monthly_charges ELSE 0 END), 2) AS revenue_lost,
        ROUND(SUM(CASE WHEN churn_value = 0 THEN monthly_charges ELSE 0 END), 2) AS revenue_at_risk
    FROM raw_customers
    GROUP BY tenure_bucket
)

SELECT
    tenure_bucket,
    total_customers,
    churned,
    retained,
    churn_rate_pct,
    revenue_lost,
    revenue_at_risk,
    ROUND(revenue_lost * 100.0 / SUM(revenue_lost) OVER(), 2) AS pct_of_total_loss
FROM tenure_revenue
ORDER BY churn_rate_pct DESC;

/*
"tenure_bucket","total_customers","churned","retained","churn_rate_pct","revenue_lost","revenue_at_risk","pct_of_total_loss"
"0-10",  1970, 968, 1002, 49.14, 63754.20, 46436.90, 45.82
"11-20",  908, 283,  625, 31.17, 21804.30, 32726.90, 15.67
"21-30",  763, 174,  589, 22.80, 14314.55, 33976.45, 10.29
"31-40",  645, 141,  504, 21.86, 11801.70, 30953.05,  8.48
"41-50",  652, 115,  537, 17.64, 10129.45, 34334.45,  7.28
"51-60",  698,  95,  603, 13.61,  8276.10, 40743.10,  5.95
"61-70",  875,  81,  794,  9.26,  7898.50, 57220.00,  5.68
"71-72",  532,  12,  520,  2.26,  1152.05, 40594.90,  0.83

Key findings:
0-10 months = 49% churn rate and 46% of total revenue lost
Almost half of all revenue loss happens in first 10 months
Churn rate drops consistently as tenure increases
After month 30 churn rate falls below 25% and keeps dropping
After month 60 churn rate falls below 10%

Business action:
Retention intervention must trigger before month 10
A loyalty or onboarding program at month 3-6 would
protect the highest revenue loss window
Customers who survive past month 30 are largely safe
*/