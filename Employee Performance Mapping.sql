
-- Create a SQLite database called SQT_HR.


-- Create tables then import data_science_team.csv proj_table.csv and emp_record_table.csv 
-- into the employee database from the given resources.

Create Table if not exists Emp_Record_Table(
	Emp_ID VARCHAR(255) Primary Key Not Null,
	First_Name VARCHAR(255) Not Null,
	Last_Name VARCHAR(255) Not Null,
	Gender VARCHAR(255),
	Role VARCHAR(255),
	Dept VARCHAR(255),
	Exp INTEGER, 
	Country VARCHAR(255),
	Continent VARCHAR(255),
	Salary Numeric,
	Emp_Rating INTEGER,
	Manager_ID VARCHAR(255),
	Proj_ID VARCHAR(255),
	Foreign Key (Proj_ID) references Proj_Table(Project_ID)
);

Create Table if not exists Data_Science_Team(
	Emp_ID VARCHAR(255) Not Null,
	First_Name VARCHAR(255) Not Null,
	Last_Name VARCHAR(255) Not Null,
	Gender VARCHAR(255),
	Role VARCHAR(255),
	Dept VARCHAR(255),
	Exp INTEGER, 
	Country VARCHAR(255),
	Continent VARCHAR(255),
	Foreign Key (Emp_ID) references Emp_Record_Table(Emp_ID)
);

Create Table if not exists Proj_Table(
	Project_ID VARCHAR(255) Primary Key Not Null,
	Proj_Name VARCHAR(255),
	Domain VARCHAR(255),
	Start_Date DATE Not Null,
	Closure_Date DATE Not Null,
	Dev_Qtr VARCHAR(255),
	Status VARCHAR(255)
);


-- Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT 
-- from the employee record table, and make a list of employees and details of their department.

Select ert.EMP_ID,
ert.FIRST_NAME,
ert.LAST_NAME,
ert.GENDER,
ert.role,
ert.DEPT,
ert.exp,
dst.role as Data_Role,
ert.country,
ert.continent
From emp_record_table ert
Left join data_science_team dst on dst.EMP_ID = ert.EMP_ID;


/* Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, 
and EMP_RATING if the EMP_RATING is: 
less than two return "Below Average", greater than four return "Above Average", 
and between two and four return "Average". */

Select ert.EMP_ID,
ert.FIRST_NAME,
ert.LAST_NAME,
ert.GENDER,
ert.role,
ert.DEPT,
ert.emp_rating,
CASE WHEN (ert.emp_rating)>4 THEN 'Above Average'
WHEN (ert.emp_rating)<2 THEN 'Below Average'
ELSE 'Average' END as Emp_Rating_Status
From emp_record_table ert
Order by ert.EMP_RATING;
-- Dorothy Wilson, Claire Brennan, and Katrina Allen are Below Average and should be placed on PIP


-- Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the 
-- Finance department from the employee table and then give the resultant column alias as NAME.

Select ert.emp_id,
concat(ert.FIRST_NAME, ' ', ert.LAST_NAME) as NAME,
ert.role,
ert.dept,
ert.exp
From emp_record_table ert
WHERE ert.dept LIKE '%FINANCE%';
-- There are 3 employees in the Finance department


-- List only those employees who have someone reporting to them. 
-- Also, show the number of reporters (including the President).

SELECT ert.emp_id,
concat(ert.FIRST_NAME, ' ', ert.LAST_NAME) as NAME,
ert.role,
ert.dept,
Count(ert2.Emp_ID) as Number_of_Reporters
FROM emp_record_table ert
INNER JOIN emp_record_table ert2 on ert.Emp_ID = ert2.Manager_ID
Group by ert.Emp_ID
Order by Number_of_Reporters desc;


-- List all the employees from the healthcare and finance departments using union. 

SELECT ert.EMP_ID
, concat(ert.FIRST_NAME, ' ', ert.LAST_NAME) as NAME
, ert.role
,ert.dept
From emp_record_table ert
where ert.dept like '%Healthcare%'
UNION ALL
SELECT ert.EMP_ID
, concat(ert.FIRST_NAME, ' ', ert.LAST_NAME) as NAME
, ert.role
,ert.dept
From emp_record_table ert
where ert.dept like '%Finance%';


-- List employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, 
-- DEPARTMENT, and EMP_RATING. Include the respective employee rating along with the 
-- max emp rating for each department.

Select ert.EMP_ID
, ert.FIRST_NAME
, ert.LAST_NAME
, ert.role
, ert.DEPT 
, ert.emp_rating
, Max(ert.emp_rating) OVER (PARTITION BY ert.dept) as Max_EmpRating_For_Dept
From emp_record_table ert;


-- Calculate the minimum and the maximum salary of the employees in each role. 

Select ert.EMP_ID
, concat(ert.FIRST_NAME, ' ', ert.LAST_NAME) as Name
, ert.role
, ert.dept
, ert.salary
, min(ert.salary) OVER (PARTITION BY ert.role) as Min_Salary_for_Role
, max(ert.salary) OVER (PARTITION BY ert.role) as Max_Salary_for_Role
From emp_record_table ert
Order by ert.role;


-- Assign ranks to each employee based on their experience. 

Select ert.EMP_ID
, concat(ert.FIRST_NAME, ' ', ert.LAST_NAME) as Name
, ert.role
, ert.dept
, ert.salary
, ert.EXP
, RANK() OVER (ORDER BY ert.exp desc) as Rank_From_Exp
, DENSE_RANK() OVER (ORDER BY ert.exp desc) as Dense_Rank_From_Exp
From emp_record_table ert
Order by ert.exp desc;


-- Create a view that displays employees in various countries whose salary 
-- is more than six thousand.

Create view Employees_with_Salary_over_6000 as
	Select ert.emp_ID
	, concat(ert.FIRST_NAME, ' ', ert.LAST_NAME) as Employee_Name
	, ert.role
	, ert.dept
	, ert.country
	, ert.salary
	from emp_record_table ert
	where ert.salary >6000;


-- Find employees with experience of more than ten years. 

Select T.emp_ID
, concat(T.FIRST_NAME, ' ', T.LAST_NAME) as Employee_Name
, T.role
, T.dept
, T.exp
From 
	(select *
	From emp_record_table ert
	Where ert.exp > 10
	) as T;


/* Write a query to check whether the job profile assigned to each employee in the 
data science team matches the organization’s set standard.The standard being:
	- For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
	- For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
	- For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
	- For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
	- For an employee with the experience of 12 to 16 years assign 'MANAGER'. */

Select ert.EMP_ID
, concat(ert.FIRST_NAME, ' ', ert.LAST_NAME) as Employee_Name
, ert.role
, ert.DEPT
, ert.exp
, CASE WHEN ert.exp <= 2 THEN 'Junior Data Scientist'
WHEN ert.exp between 2 and 5 then 'Associate Data Scientist'
When ert.exp between 5 and 10 then 'Senior Data Scientist'
when ert.exp between 10 and 12 then 'Lead Data Scientist'
when ert.exp between 12 and 16 then 'Manager'
ELSE 'Senior Management' END as Org_Standard
From emp_record_table ert
Order by ert.exp;
-- Looks like the assigned roles do match with our organization's standards


-- Calculate the bonus for all the employees, based on their 
-- ratings and salaries (Use the formula: 5% of salary * employee rating).

Select ert.EMP_ID
, concat(ert.FIRST_NAME, ' ', ert.LAST_NAME) as Employee_Name
, ert.role
, ert.SALARY
, ert.EMP_RATING
, ert.salary * 0.05 * ert.EMP_RATING as Bonus
From emp_record_table ert;


-- Calculate the average salary distribution based on the continent and country. 
-- Take data from the employee record table.

Select distinct ert.COUNTRY
, ert.CONTINENT
, AVG(ert.salary) OVER (PARTITION BY ert.country) as Avg_Salary_Country
, AVG(ert.salary) OVER (PARTITION BY ert.continent) as Avg_Salary_Continent
From emp_record_table ert
Order by ert.Continent;

