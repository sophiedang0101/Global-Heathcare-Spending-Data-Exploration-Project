-- 1. Yearly Percentage Change.
-- Calculate percentage change in Current Healthcare Expenditure(CHE)/Gross Domestic Product(GDP) 
-- ratio from the previous year for each country.
SELECT 
	Entity,
    Year,
    `CHE as percentage of GDP` AS Current_Health_Expenditure_As_Percentage_Of_Gross_Domestic_Product,
	`CHE as percentage of GDP` - LAG(`CHE as percentage of GDP`)
    OVER (PARTITION BY Entity ORDER BY Year) AS Percentage_Change_In_CHE_Over_GDP
FROM 
	healthcare_spending.`total-healthcare-expenditure-gdp`;

-- 2. Top N Countries by CHE/GDP Ratio.
-- Retrieve the top 10 countries with the highest CHE/GDP ratio in the latest available year.
SELECT 
	Entity,
    Year,
    `CHE as percentage of GDP` AS Current_Health_Expenditure_As_Percentage_Of_Gross_Domestic_Product
FROM 
	healthcare_spending.`total-healthcare-expenditure-gdp` 
WHERE 
	Year = (SELECT MAX(Year) FROM healthcare_spending.`total-healthcare-expenditure-gdp`)
ORDER BY
	`CHE as percentage of GDP` DESC
LIMIT 10;

-- 3. Countries with Consistently Increasing CHE/GDP Ratio.
-- Retrieve the countries where the CHE/GDP ratio has increased every year.
SELECT
	Entity
FROM 
	healthcare_spending.`total-healthcare-expenditure-gdp` 
GROUP BY
	Entity
HAVING
	MIN(`CHE as percentage of GDP`) < MAX(`CHE as percentage of GDP`);

-- 4. Average CHE/GDP Ratio Trend Over Time.
-- calculate the average CHE/GDP ratio for all countries over the years.
SELECT
	Entity,
	Year,
    AVG(`CHE as percentage of GDP`) AS Avg_Current_Health_Expenditure_As_Percentage_Of_Gross_Domestic_Product_Ratio
FROM
	healthcare_spending.`total-healthcare-expenditure-gdp` 
GROUP BY
	Entity,
	Year
ORDER BY
	Year;

-- 5. Yearly Total Health Expenditure.
-- calculate the total health expenditure for each year across all countries.
SELECT
	Entity,
    Year,
    SUM(`CHE as percentage of GDP`) AS Total_Health_Expenditure
FROM
	healthcare_spending.`total-healthcare-expenditure-gdp` 
GROUP BY
	Entity,
    Year
ORDER BY
	Year;
    
-- 6. Average Out-of-Pocket Expenditure by Country.
-- calculate the average out-of-pocket expenditure for each country.
SELECT
	Entity,
    Year,
    AVG(`Out-of-pocket expenditure (% of current health expenditure)`) AS Average_Out_of_Pocket_Expenditure
FROM
	healthcare_spending.`share-of-out-of-pocket-expenditure-on-healthcare`
WHERE 
	Year = (SELECT MAX(Year) FROM healthcare_spending.`share-of-out-of-pocket-expenditure-on-healthcare`)
GROUP BY
	Entity,
    Year;

-- 7. Yearly Trends in Out-of-pocket Expenditure.
-- Visualize the trend of out-of-pocket expenditure over the years for a specific country.
SELECT
	Year,
    `Out-of-pocket expenditure (% of current health expenditure)` 
FROM
	healthcare_spending.`share-of-out-of-pocket-expenditure-on-healthcare`
WHERE 
	Entity = 'United States'
ORDER BY
	`Out-of-pocket expenditure (% of current health expenditure)`;


-- 8. Percentage Change in Out-of-pocket Expenditure.
-- Calculate the percentage change in out-of-pocket expenditure 
-- from the previous year for each country.
SELECT
	Entity,
    Year,
    `Out-of-pocket expenditure (% of current health expenditure)`,
    (`Out-of-pocket expenditure (% of current health expenditure)`) - LAG(`Out-of-pocket expenditure (% of current health expenditure)`)
    OVER (PARTITION BY Entity ORDER BY Year) AS Percentage_Change
FROM
	healthcare_spending.`share-of-out-of-pocket-expenditure-on-healthcare`;

-- 9. Countries with Highest Out-of-pocket Expenditure:
-- Retrieve the countries with the highest out-of-pocket expenditure in the latest available year.
SELECT
	Year,
	Entity,
    MAX(`Out-of-pocket expenditure (% of current health expenditure)`) AS Max_Out_Of_Pocket_Expenditure
FROM
	healthcare_spending.`share-of-out-of-pocket-expenditure-on-healthcare`
WHERE
	Year = (SELECT MAX(Year) FROM healthcare_spending.`share-of-out-of-pocket-expenditure-on-healthcare`)
GROUP BY
	Year,
	Entity
ORDER BY
	Max_Out_Of_Pocket_Expenditure DESC
LIMIT 10;

-- 10. Average Domestic General Government Health Expenditure by Country:
-- Calculate the average domestic general government health expenditure for each country.
SELECT
	Entity,
    AVG(`Domestic general government health expenditure (% of GDP)`) AS Avg_Govt_Health_Expenditure
FROM 
	healthcare_spending.`public-healthcare-spending-share-gdp`
GROUP BY
	Entity;


-- 11. Yearly Trends in Domestic General Government Health Expenditure:
-- Visualize the trend of domestic general government health expenditure over the years for a specific country.
SELECT
	Entity,
    Year,
    `Domestic general government health expenditure (% of GDP)` AS Govt_Health_Expenditure
FROM 
	healthcare_spending.`public-healthcare-spending-share-gdp`
WHERE 
	Entity = 'United States'
ORDER BY
	Year;

-- 12.Yearly Average Domestic General Government Health Expenditure Trend:
-- Calculate the average domestic general government health expenditure across all countries for each year.
SELECT
	Year,
    AVG(`Domestic general government health expenditure (% of GDP)`) AS All_Countries_Avg_Govt_Health_Expenditure
FROM
	healthcare_spending.`public-healthcare-spending-share-gdp`
GROUP BY
	Year
ORDER BY 
	Year;
    
-- 13. Average Share of Population Covered by Health Insurance by Country:
-- Calculate the average share of population covered by health insurance for each country.
SELECT
	Entity,
    AVG(`Share of population covered by health insurance (ILO (2014))`) AS Avg_Heathcare_Coverage
FROM
	healthcare_spending.`health-protection-coverage`
GROUP BY
	Entity;


-- 14. Top N Countries with Highest Health Insurance Coverage:
-- Retrieve the top 5 countries with the highest share of population 
-- covered by health insurance in the latest available year.
SELECT
	hpc.Entity,
    hpc.`Share of population covered by health insurance (ILO (2014))` AS Share_Of_Popuation_Covered,
    hpc.Year AS Most_Recent_Year
FROM
    healthcare_spending.`health-protection-coverage` hpc
JOIN
	(SELECT
		Entity,
        MAX(Year) AS Most_Recent_Year
	FROM
		healthcare_spending.`health-protection-coverage`
	GROUP BY
		Entity) AS Subquery ON hpc.Entity = Subquery.Entity AND hpc.Year = Subquery.Most_Recent_Year
ORDER BY
	    `Share of population covered by health insurance (ILO (2014))` DESC
LIMIT 5;
	

-- 15. Average share of population covered by health insurance vs. average out-of-pocket expenditure.
SELECT
    hpc.Entity,
    AVG(hpc.`Share of population covered by health insurance (ILO (2014))`) AS Avg_Population_Share_Covered_By_Insurance,
    AVG(share_oop_exp.`Out-of-pocket expenditure (% of current health expenditure)`) AS Avg_Out_Of_Pocket_Expenditure
FROM
    healthcare_spending.`health-protection-coverage` AS hpc
INNER JOIN healthcare_spending.`share-of-out-of-pocket-expenditure-on-healthcare` AS share_oop_exp
ON hpc.Code = share_oop_exp.Code
GROUP BY
    hpc.Entity;