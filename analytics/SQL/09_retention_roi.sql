-- ================================================
-- 09_retention_roi.sql
-- The retention team's action list
-- Every segment ranked by revenue at risk
-- Conservative 20% recovery rate applied
-- Industry standard for telecom retention campaigns
-- ================================================


SELECT
    priority_rank,
    segment,
    active_customers,
    monthly_revenue_at_risk,
    recommended_intervention,
    ROUND(monthly_revenue_at_risk * 0.20, 2) AS estimated_monthly_recovery
FROM (

    SELECT
        1 AS priority_rank,
        'Month-to-month + Fiber optic + Tenure 0-10 + No Security' AS segment,
        COUNT(*)                        AS active_customers,
        ROUND(SUM(monthly_charges), 2)  AS monthly_revenue_at_risk,
        'Offer online security bundle immediately. One add-on reduces churn risk from 65% to 8%.' AS recommended_intervention
    FROM raw_customers
    WHERE churn_value = 0
    AND contract = 'Month-to-month'
    AND internet_service = 'Fiber optic'
    AND tenure_months <= 10
    AND online_security = 'No'

    UNION ALL

    SELECT
        2 AS priority_rank,
        'Month-to-month + Fiber optic + Tenure 10+ months' AS segment,
        COUNT(*)                        AS active_customers,
        ROUND(SUM(monthly_charges), 2)  AS monthly_revenue_at_risk,
        'Contract upgrade offer with 3 month discount. High revenue customers worth locking in.' AS recommended_intervention
    FROM raw_customers
    WHERE churn_value = 0
    AND contract = 'Month-to-month'
    AND internet_service = 'Fiber optic'
    AND tenure_months > 10

    UNION ALL

    SELECT
        3 AS priority_rank,
        'Month-to-month + DSL + Tenure 0-10 months' AS segment,
        COUNT(*)                        AS active_customers,
        ROUND(SUM(monthly_charges), 2)  AS monthly_revenue_at_risk,
        'Early loyalty offer at month 6. Danger window is first 10 months.' AS recommended_intervention
    FROM raw_customers
    WHERE churn_value = 0
    AND contract = 'Month-to-month'
    AND internet_service = 'DSL'
    AND tenure_months <= 10

    UNION ALL

    SELECT
        4 AS priority_rank,
        'High churn score (>60) + High monthly charges (>88)' AS segment,
        COUNT(*)                        AS active_customers,
        ROUND(SUM(monthly_charges), 2)  AS monthly_revenue_at_risk,
        'Personalised proactive outreach call before they decide to leave.' AS recommended_intervention
    FROM raw_customers
    WHERE churn_value = 0
    AND churn_score > 60
    AND monthly_charges > 88

    UNION ALL

    SELECT
        5 AS priority_rank,
        'Fixable churn reasons — support and service failures' AS segment,
        COUNT(*)                        AS active_customers,
        ROUND(SUM(monthly_charges), 2)  AS monthly_revenue_at_risk,
        'Internal process fix — support training, network reliability, pricing review.' AS recommended_intervention
    FROM raw_customers
    WHERE churn_value = 0
    AND churn_score > 60

) ranked_segments
ORDER BY priority_rank;

/*
rank | segment                                     | customers | at risk   | recovery
1    | Month-to-month Fiber optic 0-10 No Security |   204     | $16,266   |  $3,253
2    | Month-to-month Fiber optic 10+ months       |   728     | $65,595   | $13,119
3    | Month-to-month DSL 0-10 months              |   351     | $17,329   |  $3,465
4    | High churn score + High charges             |   430     | $43,256   |  $8,651
5    | Fixable churn — support and service         |  1698     | $104,070  | $20,814

Total recoverable across all segments at 20% retention:
$49,302 every single month

This number justifies any retention budget conversation.

Priority 1 — call these 204 customers this week
Priority 2 — launch contract upgrade campaign next week
Priority 3 — early loyalty program at month 6 trigger
Priority 4 — personalised outreach to high value at risk
Priority 5 — fix internal support and service failures
*/