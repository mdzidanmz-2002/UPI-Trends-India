CREATE DATABASE upi_analysis;
USE upi_analysis;
SHOW TABLES;
USE upi_analysis;

SELECT COUNT(*) 
FROM upi_monthly_data;
DESCRIBE upi_monthly_data;
SELECT * FROM upi_monthly_data
LIMIT 5;
SELECT Month
FROM upi_monthly_data
LIMIT 10;
SELECT Average_Transaction_Value_Rs
FROM upi_monthly_data
LIMIT 10;
SELECT COUNT(*) AS Invalid_Months
FROM upi_monthly_data
WHERE STR_TO_DATE(`Month`, '%c/%e/%Y') IS NULL;
SELECT COUNT(*) AS Blank_Averages
FROM upi_monthly_data
WHERE TRIM(`Average_Transaction_Value_Rs`) = '';
ALTER TABLE upi_monthly_data
ADD COLUMN Month_Date DATE;
SET SQL_SAFE_UPDATES = 0;
UPDATE upi_monthly_data
SET Month_Date = STR_TO_DATE(`Month`, '%c/%e/%Y');
SELECT `Month`, Month_Date
FROM upi_monthly_data
LIMIT 10;
ALTER TABLE upi_monthly_data
ADD COLUMN Average_Value_Decimal DECIMAL(12,2);
UPDATE upi_monthly_data
SET Average_Value_Decimal =
    CAST(NULLIF(TRIM(Average_Transaction_Value_Rs), '') AS DECIMAL(12,2));
SELECT Average_Transaction_Value_Rs,
       Average_Value_Decimal
FROM upi_monthly_data
LIMIT 15;
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Month_Date) AS Valid_Dates,
    COUNT(Average_Value_Decimal) AS Valid_Averages,
    SUM(Average_Value_Decimal IS NULL) AS Blank_Averages
FROM upi_monthly_data;
SELECT
    MIN(Month_Date) AS First_Month,
    MAX(Month_Date) AS Last_Month
FROM upi_monthly_data;
ALTER TABLE upi_monthly_data
CHANGE COLUMN `Month` Month_Original TEXT;
ALTER TABLE upi_monthly_data
CHANGE COLUMN Month_Date `Month` DATE;
ALTER TABLE upi_monthly_data
CHANGE COLUMN Average_Transaction_Value_Rs
Average_Value_Original TEXT;
ALTER TABLE upi_monthly_data
CHANGE COLUMN Average_Value_Decimal
Average_Transaction_Value_Rs DECIMAL(12,2);
DESCRIBE upi_monthly_data;
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Month) AS Valid_Months,
    COUNT(Average_Transaction_Value_Rs) AS Valid_Averages,
    MIN(Month) AS First_Month,
    MAX(Month) AS Last_Month
FROM upi_monthly_data;
ALTER TABLE upi_monthly_data
DROP COLUMN Month_Original,
DROP COLUMN Average_Value_Original;
DESCRIBE upi_monthly_data;
SELECT
    COUNT(*) AS Total_Months,
    SUM(`Volume (In Mn.)`) AS Total_Transaction_Volume_Mn,
    SUM(`Value (In Cr.)`) AS Total_Transaction_Value_Cr,
    AVG(`No. of Banks live on UPI`) AS Avg_Banks_Live
FROM upi_monthly_data;
SELECT
    YEAR(Month) AS Year,
    ROUND(SUM(`Volume (In Mn.)`), 2) AS Total_Volume_Mn,
    ROUND(SUM(`Value (In Cr.)`), 2) AS Total_Value_Cr
FROM upi_monthly_data
GROUP BY YEAR(Month)
ORDER BY Year;
SELECT
    YEAR(Month) AS Year,
    MIN(`No. of Banks live on UPI`) AS Starting_Banks,
    MAX(`No. of Banks live on UPI`) AS Highest_Banks,
    ROUND(AVG(`No. of Banks live on UPI`), 2) AS Average_Banks
FROM upi_monthly_data
GROUP BY YEAR(Month)
ORDER BY Year;
SELECT
    Month,
    ROUND(`Volume (In Mn.)`, 2) AS Monthly_Volume_Mn,
    ROUND(`Value (In Cr.)`, 2) AS Monthly_Value_Cr
FROM upi_monthly_data
ORDER BY Month;
SELECT
    Month,
    ROUND(`Volume (In Mn.)`, 2) AS Transaction_Volume_Mn,
    ROUND(`Value (In Cr.)`, 2) AS Transaction_Value_Cr
FROM upi_monthly_data
ORDER BY `Volume (In Mn.)` DESC
LIMIT 5;
SELECT
    Month,
    ROUND(`Volume (In Mn.)`, 2) AS Transaction_Volume_Mn,
    ROUND(`Value (In Cr.)`, 2) AS Transaction_Value_Cr
FROM upi_monthly_data
ORDER BY `Volume (In Mn.)` ASC
LIMIT 10;
SELECT
    Month,
    `Volume (In Mn.)`,
    `Value (In Cr.)`
FROM upi_monthly_data
WHERE `Volume (In Mn.)` = 0
   OR `Value (In Cr.)` = 0
ORDER BY Month;
SELECT
    YEAR(Month) AS Year,
    ROUND(SUM(`Volume (In Mn.)`), 2) AS Annual_Volume_Mn
FROM upi_monthly_data
GROUP BY YEAR(Month)
ORDER BY Year;
WITH Yearly_Volume AS (
    SELECT
        YEAR(Month) AS Year,
        SUM(`Volume (In Mn.)`) AS Annual_Volume
    FROM upi_monthly_data
    GROUP BY YEAR(Month)
)
SELECT
    Year,
    ROUND(Annual_Volume, 2) AS Annual_Volume_Mn,
    ROUND(
        (Annual_Volume - LAG(Annual_Volume) OVER (ORDER BY Year))
        / LAG(Annual_Volume) OVER (ORDER BY Year) * 100,
        2
    ) AS YoY_Growth_Percentage
FROM Yearly_Volume
ORDER BY Year;
SELECT
    YEAR(Month) AS Year,
    ROUND(SUM(`Value (In Cr.)`), 2) AS Annual_Value_Cr
FROM upi_monthly_data
GROUP BY YEAR(Month)
ORDER BY Year;
WITH Yearly_Value AS (
    SELECT
        YEAR(Month) AS Year,
        SUM(`Value (In Cr.)`) AS Annual_Value
    FROM upi_monthly_data
    GROUP BY YEAR(Month)
)
SELECT
    Year,
    ROUND(Annual_Value, 2) AS Annual_Value_Cr,
    ROUND(
        (Annual_Value - LAG(Annual_Value) OVER (ORDER BY Year))
        / LAG(Annual_Value) OVER (ORDER BY Year) * 100,
        2
    ) AS YoY_Growth_Percentage
FROM Yearly_Value
ORDER BY Year;
SELECT
    YEAR(Month) AS Year,
    ROUND(
        SUM(`Value (In Cr.)`) * 10
        / NULLIF(SUM(`Volume (In Mn.)`), 0),
        2
    ) AS Yearly_Average_Transaction_Value_Rs
FROM upi_monthly_data
GROUP BY YEAR(Month)
ORDER BY Year;
WITH Monthly_Growth AS (
    SELECT
        Month,
        `Volume (In Mn.)` AS Current_Month_Volume,
        LAG(`Volume (In Mn.)`) OVER (ORDER BY Month) AS Previous_Month_Volume
    FROM upi_monthly_data
)
SELECT
    Month,
    ROUND(Current_Month_Volume, 2) AS Current_Volume_Mn,
    ROUND(Previous_Month_Volume, 2) AS Previous_Volume_Mn,
    ROUND(
        (Current_Month_Volume - Previous_Month_Volume)
        / NULLIF(Previous_Month_Volume, 0) * 100,
        2
    ) AS MoM_Growth_Percentage
FROM Monthly_Growth
ORDER BY Month;