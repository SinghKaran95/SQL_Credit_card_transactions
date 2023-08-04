
--1) write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends

with cityspends as
(select city, sum(amount) as total_spend
from credit_card_transcations
group by city),
overallspends as 
(select sum(amount) as total_amount from credit_card_transcations)
select top 5 city,round((total_spend/total_amount *100.0),2) as percentcontribution
from cityspends
inner join overallspends on 1=1
order by total_spend desc;

--2) write a query to print highest spend month and amount spent in that month for each card type
select * from credit_card_transcations;

with cardtype as
(select card_type, datename(year,transaction_date) as [year],
datename(month,transaction_date) as [month],sum(amount) as total_spend
from credit_card_transcations
group by card_type, datename(year,transaction_date),datename(month,transaction_date))
select * from (select *, rank() over (partition by card_type order by total_spend desc) as rn from cardtype) a
where rn=1;

/*3) Write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type) */
with cte as (
select * ,sum(amount) over (partition by card_type order by transaction_date,transaction_id) as total_spend
from credit_card_transcations)
select * from (select *, rank() over (partition by card_type order by total_spend) as rn
from cte where total_spend>=1000000) a where rn=1;

--4) write a query to find city which had lowest percentage spend for gold card type
with cityspends as
(select city, sum(amount) as gold_spend
from credit_card_transcations
where card_type='Gold'
group by city),
overallspends as 
(select sum(amount) as total_amount from credit_card_transcations)
select top 1 city,(gold_spend*1.0/total_amount *100.0) as percentcontribution
from cityspends
inner join overallspends on 1=1
order by gold_spend asc;

/*5) Write a query to print 3 columns:  
city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)*/

select * from credit_card_transcations;

with cityexpense as
(select city,exp_type, sum(amount) as total_expense
from credit_card_transcations
group by city, exp_type)
select city, min(case when rnk_asc=1 then exp_type end) as lowest_expense,
max(case when rnk_desc=1 then exp_type end) as highest_expense
from
(select *,rank() over (partition by city order by total_expense asc) as rnk_asc,
rank() over(partition by city order by total_expense desc) as rnk_desc 
from cityexpense)a
group by city;

--6) write a query to find percentage contribution of spends by females for each expense type

select * from credit_card_transcations;

with femalecontr as 
(select exp_type, sum(amount) as female_spend
from credit_card_transcations
where gender='F'
group by exp_type),
totalcontr as 
(Select exp_type, sum(amount) as total_amount
from credit_card_transcations group by exp_type)
select f.*,t.total_amount,round((female_spend/total_amount*100.0),2) as [FemaleContribution]
from femalecontr f inner join totalcontr t on f.exp_type=t.exp_type
order by [FemaleContribution] desc;

--Alternate approach

select exp_type,
sum(case when gender='F' then amount else 0 end) as female_spend,sum(amount) as total_spend,
(sum(case when gender='F' then amount else 0 end)/sum(amount)*100.0) as percentage_female_contribution
from credit_card_transcations
group by exp_type
order by percentage_female_contribution desc;

--7) which card and expense type combination saw highest month over month growth in Jan-2014

with combination as (
select card_type,exp_type,datepart(year,transaction_date) as [year],
datepart(month,transaction_date) as [month], sum(amount) as total_spend
from credit_card_transcations
group by card_type,exp_type,datepart(year,transaction_date),datepart(month,transaction_date))
select * ,(total_spend -prev_month_spend) as momgrowth from
(select *, lag(total_spend,1) over (partition by card_type,exp_type order by [year],[month]) 
as prev_month_spend from combination)a
where prev_month_spend is not null and [year]=2014 and [month]=01 
order by  momgrowth desc

--9) During weekends which city has highest total spend to total no of transcations ratio 

select top 1 city,count(transaction_id) as transactions,sum(amount) as total_spends,
sum(amount)/count(transaction_id) as transaction_ratio
from credit_card_transcations
where datename(WEEKDAY,transaction_date) in ('Saturday','Sunday')
group by city
order by transaction_ratio desc

/*10) which city took least number of days to reach its 500th transaction after the
first transaction in that city*/

with t1 as 
(select *, row_number() over ( partition by city order by transaction_date,transaction_id) as rown
from credit_card_transcations)
select top 1 city,datediff(day,min(transaction_date),max(transaction_date)) as daysdiff
from t1
where rown=1 or rown=500
group by city
having count(1)=2
order by daysdiff






















