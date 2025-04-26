
-- We are conducting exploratory analysis of our retail data
-- We have cleaned the data prior in Excel

-- Create a new table for our data
Create Table if not exists retail_data(
	ID Integer Primary Key Not Null
	, Birth_Year Integer
	, Education Varchar(255)
	, Marital_Status Varchar(255)
	, Income Integer
	, Kid_home Integer
	, Teen_home Integer
	, Date_Customer Date
	, Recency Integer
	, Mnt_Wines Integer
	, Mnt_Fruits Integer
	, Mnt_MeatProducts Integer
	, Mnt_FishProducts Integer
	, Mnt_SweetProducts Integer
	, Mnt_GoldProds Integer
	, Num_DealsPurchases Integer
	, Num_WebPurchases Integer
	, Num_CatalogPurchases Integer
	, Num_StorePurchases Integer
	, Num_WebVisitsMonth Integer
	, AcceptedCmp_1 Boolean
	, AcceptedCmp_2 Boolean
	, AcceptedCmp_3 Boolean
	, AcceptedCmp_4 Boolean
	, AcceptedCmp_5 Boolean
	, Complain Boolean
	, Response Boolean
	, Age_calc Integer
	, Age_group Varchar(255)
	, ct_customer Date
);

select *
from retail_data rd;


-- Calculate the total number of customer encounters in the marketing campaign dataset

	-- Total Number of Web Visits
	select sum(Num_WebVisitsMonth) as Total_WebVisits
	from retail_data rd;
	
-- Calculate the total number of promotions accepted by customers in each Campaign
	select sum(AcceptedCmp_1) as Cmp1_Sum
	, sum(AcceptedCmp_2) as Cmp2_Sum
	, sum(AcceptedCmp_3) as Cmp3_Sum
	, sum(AcceptedCmp_4) as Cmp4_Sum
	, sum(AcceptedCmp_5)as Cmp5_Sum
	, sum(Response) as Cmp6_Sum
	from retail_data rd;
	
	-- Total number of accepted promotions total
	select sum(AcceptedCmp_1) + sum(AcceptedCmp_2) + sum(AcceptedCmp_3)
	+ sum(AcceptedCmp_4) + sum(AcceptedCmp_5) + sum(Response) as AcceptedCmp_Total
	from retail_data rd;
	
	-- Average of Accepted promotions per Campaign
	select Round(AVG(AcceptedCmp_1),3) as Cmp1_Avg
	, Round(AVG(AcceptedCmp_2),3) as Cmp2_Avg
	, Round(AVG(AcceptedCmp_3),3) as Cmp3_Avg
	, Round(AVG(AcceptedCmp_4),3) as Cmp4_Avg
	, Round(AVG(AcceptedCmp_5),3) as Cmp5_Avg
	, Round(Avg(Response),3) as Cmp6_Avg
	from retail_data rd;


-- Find the count of Response values
select count(Response) as Count_of_Responses
from retail_data rd;

-- Determine the distribution of customers based on their 
-- education level and marital status
Select Education
, Count(ID) as Number_of_Customers
from retail_data rd
Group by Education;

Select Marital_Status
, Count(ID) as Number_of_Customers
from retail_data rd
Group by Marital_Status;

-- Identify the Average Income of Customers who participated in the marketing campaign

	Select Round(Avg(Income),2) as Avg_Income_for_AllCmp
	From retail_data rd
	Where AcceptedCmp_1 = 1 or AcceptedCmp_2 = 1 or AcceptedCmp_3 = 1
	or AcceptedCmp_4 = 1 or AcceptedCmp_5 = 1 or Response = 1
	
	Select Round(Avg(Income),2) as Avg_Income_for_Cmp1
	From retail_data rd
	Where AcceptedCmp_1 = 1
	
	Select Round(Avg(Income),2) as Avg_Income_for_Cmp2
	From retail_data rd
	Where AcceptedCmp_2 = 1
	
	Select Round(Avg(Income),2) as Avg_Income_for_Cmp3
	From retail_data rd
	Where AcceptedCmp_3 = 1
	
	Select Round(Avg(Income),2) as Avg_Income_for_Cmp4
	From retail_data rd
	Where AcceptedCmp_4 = 1
	
	Select Round(Avg(Income),2) as Avg_Income_for_Cmp5
	From retail_data rd
	Where AcceptedCmp_5 = 1

	Select Round(Avg(Income),2) as Avg_Income_for_Cmp6
	From retail_data rd
	Where Response = 1

-- Identify the distribution of customers' responses to the last campaign (Campagin 6)

Select SUM(Response) as Total_Responses_Cmp6
, Round(Avg(Response),3) as Avg_Responses_Cmp6
From retail_data rd;

-- Calculate the average number of children and teenagers in customers' households
select Round(AVG(Kid_home),2) as Avg_Number_of_Kids
, Round(AVG(Teen_home),2) as Avg_Number_of_Teens
From retail_data rd;

-- Determine the average number of visits per month for customers in each Age Group
select Age_group
, Round(avg(Num_WebVisitsMonth),2) as Avg_Num_WebVisitsMonth
from retail_data rd
Group by Age_group;
	

-- Total Number of Purchases total
select sum(Num_DealsPurchases) + sum(Num_WebPurchases) 
+ sum(Num_CatalogPurchases) + sum(Num_StorePurchases) as Num_TotalPurchases
from retail_data rd;

-- Total Purchases per Method
select sum(Num_DealsPurchases) as DealsPurchases_Sum
, sum(Num_WebPurchases) as WebPurchases_Sum
, sum(Num_CatalogPurchases) as CatalogPurchases_Sum
, sum(Num_StorePurchases) as StorePurchases_Sum
from retail_data rd;

-- Average Number of Purchases per Method
select Round(AVG(Num_DealsPurchases),2) as DealsPurchases_Avg
, Round(AVG(Num_WebPurchases),2) as WebPurchases_Avg
, Round(AVG(Num_CatalogPurchases),2) as CatalogPurchases_Sum
, Round(AVG(Num_StorePurchases),2) as StorePurchases_Sum
from retail_data rd;

-- Total Purchases per Product Category
select sum(Mnt_Wines) as Wines_Purchases
, sum(Mnt_Fruits) as Fruits_Purchases
, sum(Mnt_MeatProducts) as Meat_Purchases
, sum(Mnt_FishProducts) as Fish_Purchases
, sum(Mnt_SweetProducts)as Sweet_Purchases
, sum(Mnt_GoldProds)as Gold_Purchases
from retail_data rd;

-- Average Purchases per Product Category
select Round(AVG(Mnt_Wines),2) as Wines_Avg
, Round(AVG(Mnt_Fruits),2) as Fruits_Avg
, Round(AVG(Mnt_MeatProducts),2) as Meat_Avg
, Round(AVG(Mnt_FishProducts),2) as Fish_Avg
, Round(AVG(Mnt_SweetProducts),2) as Sweet_Avg
, Round(AVG(Mnt_GoldProds),2) as Gold_Avg
from retail_data rd;




	
	
	
	