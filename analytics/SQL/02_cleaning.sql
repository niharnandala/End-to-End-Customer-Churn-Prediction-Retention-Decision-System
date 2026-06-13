--Task 1--Explore shape of the table

SELECT 
(SELECT count(*) from raw_customers) as row_count,
(select count(*) from information_schema.columns
where table_name='raw_customers') as column_count;

select column_name from information_schema.columns
where table_name='raw_customers'

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

-- check if it looks right
SELECT * FROM raw_customers LIMIT 5;

commit;


SELECT * FROM raw_customers LIMIT 5;


--check the information we get from information_schema
select * from information_schema.columns where table_name='raw_customers' LIMIT 1;

--get column_names|date_type to verify data type mismatch

select column_name,data_type from information_schema.columns where table_name='raw_customers';

select tenure_months,total_charges from raw_customers where total_charges !~ '^\d+(\.\d+)?$'

SELECT tenure_months, monthly_charges, total_charges 
FROM raw_customers 
WHERE total_charges !~ '^\d+(\.\d+)?$';

--TENURE MONTHS are 0 thats why total_cahrges are blank,
lets fill total_charge-blank to '0'--

Begin;
update raw_customers
set total_charges='0'
where total_charges !~ '^\d+(\.\d+)?$';


Commit;

select count(total_charges) from raw_customers where total_charges !~ '^\d+(\.\d+)?$'

Alter table raw_customers 
Alter column total_charges type numeric
using total_charges::Numeric

select column_name,data_type from information_schema.columns where column_name='total_charges';
select column_name,data_type from information_schema.columns where column_name='monthly_charges';

select tenure_months,total_charges from raw_customers where tenure_months=1;

SELECT COUNT(*) FROM raw_customers;
