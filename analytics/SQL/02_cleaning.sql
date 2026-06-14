-- ================================================
-- 02_cleaning.sql
-- Purpose: Clean raw_customers table before analysis
-- All issues identified during ML pipeline exploration
-- (see notebooks/ for full EDA)
-- ================================================


-- Step 1: Drop columns with no analytical value
-- Geographic columns — all customers are in California
-- No geographic variation exists to analyse
-- Count column — redundant row counter

BEGIN;

ALTER TABLE raw_customers
DROP COLUMN zip_code,
DROP COLUMN country,
DROP COLUMN state,
DROP COLUMN latitude,
DROP COLUMN longitude,
DROP COLUMN lat_long,
DROP COLUMN count,
DROP COLUMN city;

COMMIT;

-- Result: 25 columns remain from original 33


-- ================================================

-- Step 2: Fix blank total_charges values
-- 11 customers have blank total_charges
-- All have tenure_months = 0
-- They just joined and have not completed one billing cycle
-- Correct value is 0 — they have been charged nothing yet

BEGIN;

UPDATE raw_customers
SET total_charges = '0'
WHERE total_charges !~ '^\d+(\.\d+)?$';

COMMIT;

-- Note: total_charges is stored as TEXT because blank spaces
-- prevent PostgreSQL from loading it as NUMERIC directly
-- We fix the blanks first then convert the column type below


-- ================================================

-- Step 3: Convert total_charges from TEXT to NUMERIC
-- Now that blanks are fixed all values are valid numbers
-- Safe to convert

ALTER TABLE raw_customers
ALTER COLUMN total_charges TYPE NUMERIC
USING total_charges::NUMERIC;


-- ================================================

-- Step 4: Final row count check
-- Confirms no rows were accidentally deleted during cleaning

SELECT COUNT(*) AS total_rows FROM raw_customers;

-- Expected: 7043


-- ================================================

-- Data quality notes
-- churn_reason is NULL for non-churned customers
-- This is expected — NULL means did not churn, not missing data
-- No duplicate rows exist in this dataset
-- No unexpected nulls found in any other column
-- Monthly charges and tenure months have no impossible values
-- Outliers in numerical columns are real customer data not errors