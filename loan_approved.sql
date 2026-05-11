-- Create a database
create database finance; 

use finance;

select * from loan_approved_clean_data;

-- rename table name
rename table loan_approved_clean_data to loan;

select * from loan;

alter table loan 
drop column myunknowncolumn;

--------------- SECTION 1 — Basic SQL Queries -------

-- 1. View the first 10 records from the table. 
select * from loan
limit 10;

-- 2. Count the total number of loan applications.
select count(*) from loan;

-- 3. List all unique property areas.
select distinct(Property_Area) 
from loan;

-- 4. Show all applicants who are self-employed and have an income above 5000. 
select * from loan
where Self_Employed = 'Yes' and ApplicantIncome > 5000;

select count(*) from loan
where Self_Employed = 'Yes' and ApplicantIncome > 5000;

-- 5. Find the total number of approved loans. 
select count(*) from loan
where Loan_Status = 'Y' ;

---------------------- SECTION 2 — Aggregation & Grouping -----------

-- 6. Find average loan amount by education level. 
select avg(LoanAmount) from loan;

select Education, round(avg(LoanAmount),3) as avg_loan
from loan
group by education;

-- 7. Find average total income (Applicant + Coapplicant) by marital status. 
select Married, round(avg(ApplicantIncome + CoapplicantIncome ),2) as avg_total_income
from loan
group by Married;

-- 8. Show average loan amount by credit history. 
select Credit_History, round(avg(LoanAmount),2) as avg_loan
from loan
group by Credit_History;

-- 9. Find total applications and approval rate by gender. 
select gender, 
	count(*) as total_applicants,
    sum(case when loan_status = "Y" then 1 else 0 end) as approvals,
    round(sum(case when loan_status = "Y" then 1 else 0 end)/count(*)*100,2) as approval_rate
from loan
group by gender ;

-- 10. Show approval rate by property area. 
select Property_Area , 
	   round(sum(case when loan_status = "Y" then 1 else 0 end)/count(*)*100,2) as approval_rate
from loan
group by Property_Area;

--------------- SECTION 3 — Filtering & Conditions 

-- 11. Show applicants who are graduates, not self-employed, and have loan amount greater than 150. 
select * 
from loan
where Education = 'graduate' 
	  and Self_Employed = 'no' 
      and LoanAmount > 150;

-- 12. Display approved loans from urban area with good credit history. 
select * from loan
where Property_Area = 'urban' and Credit_History = 1;

-- 13. List top 5 applicants with highest total income. 
select * , (ApplicantIncome + CoapplicantIncome) as total_income from loan
order by (total_income) desc
limit 5;

--------- SECTION 4 — Derived Columns & CASE WHEN 

-- 14. Create derived columns for total income for each applicant. 
select * ,(ApplicantIncome + CoapplicantIncome) as total_income 
from loan;

-- 15. Classify applicants into income groups (Low, Medium, High) based on applicant income.
select loan_id,total_income, 
		case 
			when total_income >= 7000 then 'High'
            when total_income between 3000 and 6000 then 'Medium'
            else 'Low'
        end as income_group
from (
    select *,
           ApplicantIncome + CoapplicantIncome AS total_income
    from loan
) as income_data;
 
-- 16. Find average loan amount for each income group.
select 
		case 
			when ApplicantIncome >= 7000 then 'High'
            when ApplicantIncome between 3000 and 6000 then 'Medium'
            else 'Low'
        end as income_group,
        round(avg(LoanAmount),2) as avg_loanAmount
from loan
group by income_group;


--------------- SECTION 5 — Subqueries & Nested Analysis 

-- 17. Find applicants whose loan amount is greater than the overall average loan amount. 
select * from loan
where LoanAmount > (
			select avg(LoanAmount) 
            from loan);
            
-- 18. Identify the property area with the highest average total income. 
select Property_Area, avg(ApplicantIncome + CoapplicantIncome) as total_income
from loan
group by Property_Area
order by total_income desc 
limit 1;


-- 19. List all applicants whose income is above the average income of their education category. 


------------ SECTION 6 — Window Functions 

-- 20. Rank applicants based on total income (highest income rank = 1). 
select Loan_ID ,
		ApplicantIncome + CoapplicantIncome as total_income,
        rank() over (order by (ApplicantIncome + CoapplicantIncome) desc) as Rank_number
from loan;                    


-- 21. Show average loan amount per property area using a window function. 
select Loan_ID, Property_Area,LoanAmount,
		avg(LoanAmount) 
		over ( partition by Property_Area) as avg_Area_loan
from loan;

						-- or
                        
select distinct (Property_Area),
			avg(LoanAmount) over(partition by Property_Area) as avg_Area_loan
from loan;

-- 22. Calculate approval rate by education using grouping or window function. 


------------- SECTION 7 — Business Insights & Combined Analysis 

-- 23. Compare approval rate by credit history and education level to find which combination performs best. 
select Credit_History, Education, count(*) as total_applicants,
		sum(case when Loan_Status = 'Y' then 1 else 0 end) as approvals,
        round(sum(case when Loan_Status = 'Y' then 1 else 0 end)/count(*)*100,2) as approval_rate
from loan
group by Credit_History, Education
order by approval_rate desc;


-- 24. Find the combination of property area and education with the highest approval rate. 
select property_Area,
       education, 
	   count(*) as total_applicants, 
       sum(case when loan_status = 'Y' then 1 else 0 end) as approvals,
	   round(sum(case when loan_status = 'Y' then 1 else 0 end)/count(*)*100, 2) as approval_rate
from loan 
group by property_Area, education
order by approval_rate desc;

-- 25. Compare approval rate for self-employed vs non-self-employed applicants by credit history.
select Self_Employed,
       Credit_History, 
	   count(*) as total_applicants, 
       sum(case when loan_status = 'Y' then 1 else 0 end) as approvals,
	   round(sum(case when loan_status = 'Y' then 1 else 0 end)/count(*)*100, 2) as approval_rate
from loan 
group by Self_Employed, Credit_History
order by approval_rate desc;