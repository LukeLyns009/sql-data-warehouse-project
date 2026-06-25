/*
===================================================================
Quality Checks
===================================================================
Script Purpose
    This script performs various checks for data consistency, accuracy,
    and standardisation across the 'silver' schemma. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardisation and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.
Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
====================================================================
*/
-- Check for NULLS or Duplicates in Primary Key
-- Expectation: No Results
SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info -- For bronze schema
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info -- For silver schema
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
-- Check Unwanted Spaces
-- Expectation: No Results
SELECT prd_nm
FROM bronze.crm_prd_info   -- For bronze schema
WHERE prd_nm != TRIM(prd_nm);

SELECT prd_nm
FROM silver.crm_prd_info    -- For silver schema
WHERE prd_nm != TRIM(prd_nm);

SELECT cst_lastname
FROM silver.crm_cust_info     -- For silver schema
WHERE cst_lastname != TRIM(cst_lastname);

-- Data Standardisation & Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;     -- For bronze schema

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;     -- For silver schema

-- Checks for NULLS or Negative Numbers
-- Expectation: No results
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
                                             -- For bronze schema
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat !=TRIM(subcat) OR maintenance != TRIM(maintenance);


SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
                                              -- For silver schema
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Data Standardisation & Consistency
SELECT DISTINCT
cntry
FROM bronze.erp_loc_a101;
                                                -- For bronze schema
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;

SELECT DISTINCT 
cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT 
subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT 
maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT
cntry
FROM silver.erp_loc_a101;
                                                 -- For silver schema
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT
gen,
CASE 
    WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
    WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
    ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12;                         -- For bronze schema

SELECT DISTINCT 
cntry AS old_cntry,
CASE
    WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
    WHEN TRIM(cntry) ='' OR cntry IS NULL THEN 'n/a'
    ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;

-- Check for Invalid Date Orders
SELECT *
FROM bronze.crm_sales_details                     -- For bronze schema
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

SELECT *
FROM silver.crm_sales_details                     -- For silver schema
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

--Check for Invalid Dates
SELECT
sls_ship_dt
FROM bronze.crm_sales_details                      -- For bronze schema
WHERE sls_ship_dt <= 0 OR LEN(sls_ship_dt) !=8 OR sls_ship_dt >20500101 OR sls_ship_dt < 19000101;

SELECT
sls_ship_dt
FROM silver.crm_sales_details                       -- For silver schema
WHERE sls_ship_dt <= 0 OR LEN(sls_ship_dt) !=8 OR sls_ship_dt >20500101 OR sls_ship_dt < 19000101;

-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.
SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price;

-- Identify Out-of-Range Dates
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1926-01-01' OR bdate > GETDATE()

-- Data 
SELECT * FROM silver.erp_cust_az12;
