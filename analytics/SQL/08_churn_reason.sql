-- ================================================
-- 08_churn_reason.sql
-- Question: Why are customers actually leaving
-- and how much is each reason costing the business?
-- ================================================


-- Step 1: Revenue lost by each churn reason
-- Ordered by revenue impact not customer count
-- Because not all customers cost the same when they leave

SELECT
    churn_reason,
    COUNT(*)                        AS total_customers,
    ROUND(SUM(monthly_charges), 2)  AS revenue_lost
FROM raw_customers
WHERE churn_value = 1
GROUP BY churn_reason
ORDER BY revenue_lost DESC;

/*
Competitor offered higher download speeds → 189 customers → $14,144
Attitude of support person               → 192 customers → $13,980
Competitor offered more data             → 162 customers → $12,351
Don't know                               → 154 customers → $11,099
Competitor made better offer             → 140 customers → $10,672
Attitude of service provider             → 135 customers → $10,399
Competitor had better devices            → 130 customers →  $9,432
Product dissatisfaction                  → 102 customers →  $7,528
Network reliability                      → 103 customers →  $7,497
Price too high                           →  98 customers →  $7,398
*/


-- ================================================

-- Step 2: Categorise each reason as Fixable,
-- Competitor or Not Fixable
-- Not all churn is worth acting on equally
-- Fixable = internal failure the business caused
-- Competitor = external pressure
-- Not Fixable = nothing the business can do

SELECT
    churn_reason,
    COUNT(*)                        AS total_customers,
    ROUND(SUM(monthly_charges), 2)  AS revenue_lost,
    CASE
        WHEN churn_reason IN (
            'Attitude of support person',
            'Attitude of service provider',
            'Network reliability',
            'Price too high',
            'Service dissatisfaction',
            'Product dissatisfaction',
            'Lack of self-service on Website',
            'Extra data charges',
            'Long distance charges',
            'Poor expertise of phone support',
            'Poor expertise of online support',
            'Limited range of services'
        ) THEN 'Fixable'
        WHEN churn_reason IN (
            'Competitor offered higher download speeds',
            'Competitor offered more data',
            'Competitor made better offer',
            'Competitor had better devices',
            'Lack of affordable download/upload speed'
        ) THEN 'Competitor'
        WHEN churn_reason IN (
            'Moved',
            'Deceased',
            'Don''t know'
        ) THEN 'Not Fixable'
    END AS category
FROM raw_customers
WHERE churn_value = 1
GROUP BY churn_reason
ORDER BY revenue_lost DESC;


-- ================================================

-- Step 3: Total revenue lost by category
-- This is the executive level view of why revenue bled

SELECT
    CASE
        WHEN churn_reason IN (
            'Attitude of support person',
            'Attitude of service provider',
            'Network reliability',
            'Price too high',
            'Service dissatisfaction',
            'Product dissatisfaction',
            'Lack of self-service on Website',
            'Extra data charges',
            'Long distance charges',
            'Poor expertise of phone support',
            'Poor expertise of online support',
            'Limited range of services'
        ) THEN 'Fixable'
        WHEN churn_reason IN (
            'Competitor offered higher download speeds',
            'Competitor offered more data',
            'Competitor made better offer',
            'Competitor had better devices',
            'Lack of affordable download/upload speed'
        ) THEN 'Competitor'
        WHEN churn_reason IN (
            'Moved',
            'Deceased',
            'Don''t know'
        ) THEN 'Not Fixable'
    END AS category,
    COUNT(*)                        AS total_customers,
    ROUND(SUM(monthly_charges), 2)  AS revenue_lost
FROM raw_customers
WHERE churn_value = 1
GROUP BY category
ORDER BY revenue_lost DESC;

/*
Fixable      → 991 customers → $73,704 lost monthly
Competitor   → 665 customers → $49,785 lost monthly
Not Fixable  → 213 customers → $15,640 lost monthly

Key finding:
$73,704 every month was lost to problems the business
created itself. Bad support. Network issues. Pricing gaps.
This is 48% more than competitor losses.

Fix internal problems first before competing externally.
The data says the biggest enemy is not the competitor.
It is poor service delivery.
*/