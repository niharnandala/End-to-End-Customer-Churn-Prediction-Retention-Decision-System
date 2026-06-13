-- ================================================
-- 06_services.sql
-- Question: Which service combinations are bleeding
-- the most revenue through churn?
-- ================================================


-- Step 1: Does having more services reduce churn?
-- Count total services per customer and check churn rate

WITH service_count AS (
    SELECT
        customer_id,
        churn_value,
        monthly_charges,
        (
            CASE WHEN phone_service     = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN multiple_lines    = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN online_security   = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN online_backup     = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN tech_support      = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN streaming_tv      = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN streaming_movies  = 'Yes' THEN 1 ELSE 0 END
        ) AS number_of_services
    FROM raw_customers
)

SELECT
    number_of_services,
    COUNT(*)                                                                     AS total_customers,
    SUM(churn_value)                                                             AS churned,
    COUNT(*) - SUM(churn_value)                                                  AS retained,
    ROUND(AVG(churn_value) * 100, 2)                                             AS churn_rate_pct,
    ROUND(SUM(CASE WHEN churn_value = 1 THEN monthly_charges ELSE 0 END), 2)     AS revenue_lost,
    ROUND(SUM(CASE WHEN churn_value = 0 THEN monthly_charges ELSE 0 END), 2)     AS revenue_at_risk
FROM service_count
GROUP BY number_of_services
ORDER BY churn_rate_pct DESC;

/*
number_of_services | churn_rate_pct | revenue_lost
0                  | 44%            | $869
3                  | 36%            | $27,025
2                  | 33%            | $25,748
4                  | 31%            | $25,071
5                  | 26%            | $22,024
6                  | 22%            | $15,523
1                  | 21%            | $16,423
7                  | 12%            | $5,196
8                  | 5%             | $1,248

Finding:
Every additional service a customer has reduces churn rate
0 services = 44% churn vs 8 services = 5% churn
More services = more switching friction = higher retention
*/


-- ================================================

-- Step 2: Churn rate and revenue by internet service type
-- Internet service is the single most important service column

SELECT
    internet_service,
    COUNT(*)                                                                     AS total_customers,
    ROUND(AVG(churn_value) * 100, 2)                                             AS churn_rate_pct,
    ROUND(SUM(CASE WHEN churn_value = 1 THEN monthly_charges ELSE 0 END), 2)     AS revenue_lost,
    ROUND(SUM(CASE WHEN churn_value = 0 THEN monthly_charges ELSE 0 END), 2)     AS revenue_at_risk,
    ROUND(AVG(
        CASE WHEN phone_service     = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN multiple_lines    = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN online_security   = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN online_backup     = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN tech_support      = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN streaming_tv      = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN streaming_movies  = 'Yes' THEN 1 ELSE 0 END
    ), 0)                                                                        AS avg_services
FROM raw_customers
GROUP BY internet_service
ORDER BY revenue_lost DESC;

/*
internet_service | churn_rate_pct | revenue_lost  | avg_services
Fiber optic      | 42%            | $114,300      | 4
DSL              | 19%            | $22,529       | 4
No               |  7%            |  $2,301       | 1

Finding:
Fiber optic and DSL customers have the same average number
of services (4) but Fiber optic churns at 2x the rate
This is a service quality or value perception problem
not a product bundle problem
*/


-- ================================================

-- Step 3: Full service combination analysis
-- Which exact combination of services has the worst churn?
-- Only combinations with 100+ customers are meaningful

SELECT
    phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies,
    COUNT(*)                                                                     AS total_customers,
    SUM(churn_value)                                                             AS churned,
    ROUND(AVG(churn_value) * 100, 2)                                             AS churn_rate_pct,
    ROUND(SUM(CASE WHEN churn_value = 1 THEN monthly_charges ELSE 0 END), 2)     AS revenue_lost,
    ROUND(SUM(CASE WHEN churn_value = 0 THEN monthly_charges ELSE 0 END), 2)     AS revenue_at_risk
FROM raw_customers
GROUP BY
    phone_service, multiple_lines, internet_service,
    online_security, online_backup, device_protection,
    tech_support, streaming_tv, streaming_movies
HAVING COUNT(*) >= 100
ORDER BY churn_rate_pct DESC;

/*
Top findings from combinations above 100 customers:

Fiber optic + no security add-ons = 59-66% churn rate
Fiber optic + all security add-ons = 8% churn rate

Same internet service. Completely opposite churn rates.

Key finding:
Fiber optic customers without online security, device
protection and tech support churn at 8x the rate of
fully protected customers.

Business action:
Bundle security add-ons with all new Fiber optic plans
A customer paying $80/month who adds security bundle
at $10/month reduces their churn risk from 65% to 8%
That trade-off protects far more revenue than it costs
*/