-- Create table off of the CSV

Create Table if not exists Kaggle_Retail(
	InvoiceNo Integer,
	StockCode Integer,
	Description Varchar(255),
	Quantity Integer,
	InvoiceDate Date,
	UnitPrice Numeric,
	CustomerID Integer,
	Country Varchar(255)
);

-- Check that the data imported correctly
Select *
From Kaggle_Retail;

-- Check which customer spent the most
Select CustomerID
, Sum(Quantity * UnitPrice) as Total_Spent
From Kaggle_Retail
Group by CustomerID
Order by Total_Spent desc;

-- Seeing that there are CustomerID's that are blank, so want to check how many
SELECT COUNT(*) 
FROM Kaggle_Retail 
WHERE CustomerID IS NULL;

-- Nothing showed up in the previous query, so checking for Nulls in a different way
SELECT CustomerID
, Quantity
, UnitPrice
FROM Kaggle_Retail
WHERE CustomerID = '';

-- Now let's see how many CustomerID's are blank
SELECT COUNT(*) as Number_of_Blank_CustomerIDs
FROM Kaggle_Retail 
WHERE TRIM(CustomerID) = '';
-- 135,080 blank CustomerID's

-- Now let's see which Customer spent the most (excluding blank ID's)
Select CustomerID
, Sum(Quantity * UnitPrice) as Total_Spent
From Kaggle_Retail
WHERE TRIM(CustomerID) is not ''
Group by CustomerID
Order by Total_Spent desc;
-- Customer 14646 spent $279,489.02

-- Let's see how many distinct Customers we have
Select Count(Distinct CustomerID) as Number_of_Distinct_Customers
From Kaggle_Retail
WHERE TRIM(CustomerID) is not '';
-- 4,372 distinct customers

-- Let's see what Countries we had orders from
Select Country
From Kaggle_Retail
Group by Country;

-- How many Countries did we have orders from?
Select Count(Distinct Country) as Number_of_Countries
From Kaggle_Retail;
-- 38 different countries

-- Let's see which Country had the most units sold
Select Country
, Sum(Quantity) as Total_Units_Sold
From Kaggle_Retail
Group by Country
Order by Total_Units_Sold desc
-- The UK sold 4,263,829 units followed by Netherlands at 200,128

-- Which country had the most profit?
Select Country
, Sum(Quantity * UnitPrice) as Total_Profit
From Kaggle_Retail
Group by Country
Order by Total_Profit desc
-- The UK had the most profit, followed by Netherlands

-- Which product sold the most units?
Select StockCode
, Description
, Sum(Quantity) as Total_Units_Sold
From Kaggle_Retail
Group by StockCode
Order by Total_Units_Sold desc;
-- StockCode 22197 Small Popcorn Holder sold 56,450 units

-- Which product made the most money?
Select StockCode 
, Description
, Sum(Quantity * UnitPrice) as Total_Profit
From Kaggle_Retail
Group by StockCode
Order by Total_Profit desc;
-- After postage, the Regency Cakestand made the most money

-- Let's show the Top 5 Products (most units sold) per Country
SELECT *
FROM 
(
	SELECT Country
	, Description AS Product
	, SUM(Quantity) AS Total_Units_Sold
	, RANK() OVER (PARTITION BY Country ORDER BY SUM(Quantity) DESC) AS Rank
	FROM Kaggle_Retail
	GROUP BY Country, Description
) as A
WHERE Rank <= 5;


-- Now let's show the Top 5 Products (most profit) per Country
SELECT *
FROM 
(
	SELECT Country
	, Description AS Product
	, SUM(Quantity * UnitPrice) AS Total_Profit
	, RANK() OVER (PARTITION BY Country ORDER BY SUM(Quantity * UnitPrice) DESC) AS Rank
	FROM Kaggle_Retail
	GROUP BY Country, Description
) as A
WHERE Rank <= 5;


