select * 
from dbo.Global_YouTube_Earnings


select * 
from dbo.Global_YouTube_Subscriptions



-- Renaming columns replacing spaces with underscore sign

sp_rename 'dbo.Global_YouTube_Subscriptions.video views', 'video_views'

sp_rename 'dbo.Global_YouTube_Earnings.Gross tertiary education enrollment (%)', 'Gross_tertiary_education_enrollment_percentage'

sp_rename 'dbo.Global_YouTube_Earnings.Unemployment rate', 'unemployment_rate'


-- Checking if there are any duplicate rows in both tables


with Duplicate_CTE_Subs as(
select *,
ROW_NUMBER () over (partition by Youtuber, subscribers, video_views,category order by subscribers) as row_num
from dbo.Global_YouTube_Subscriptions)
select *
from Duplicate_CTE_Subs
where row_num > 1


with Duplicate_CTE_Earnings as(
select Title, uploads, Country, channel_type,
ROW_NUMBER () over (partition by Title, uploads, Country, channel_type, video_views_for_the_last_30_days order by uploads) as row_num
from Global_YouTube_Earnings)
select *
from Duplicate_CTE_Earnings
where row_num > 1


-- Merging year, month and date columns into a single one and converting data type to date

select distinct created_month
from dbo.Global_YouTube_Earnings




alter table Global_YouTube_Earnings
add created_month_num varchar (50);


update Global_YouTube_Earnings
set created_month_num = case when created_month = 'Jan' then '01' 
     when created_month = 'Feb' then '02'
	 when created_month = 'Mar' then '03'
	 when created_month = 'Apr' then '04'
	 when created_month = 'May' then '05'
	 when created_month = 'Jun' then '06'
	 when created_month = 'Jul' then '07'
	 when created_month = 'Aug' then '08'
	 when created_month = 'Sep' then '09'
	 when created_month = 'Oct' then '10'
	 when created_month = 'Nov' then '11'
	 when created_month = 'Dec' then '12'
	 end;



select distinct created_date
from dbo.Global_YouTube_Earnings
order by created_date desc


alter table dbo.Global_YouTube_Earnings
add created_date_new varchar (50)


update Global_YouTube_Earnings
set created_date_new = case when created_date = 1 then '01'
     when created_date = 2 then '02'
	 when created_date = 3 then '03'
	 when created_date = 4 then '04'
	 when created_date = 5 then '05'
	 when created_date = 6 then '06'
	 when created_date = 7 then '07'
	 when created_date = 8 then '08'
	 when created_date = 9 then '09'
	 when created_date = 10 then '10'
	 when created_date = 11 then '11'
	 when created_date = 12 then '12'
	 when created_date = 13 then '13'
	 when created_date = 14 then '14'
	 when created_date = 15 then '15'
	 when created_date = 16 then '16'
	 when created_date = 17 then '17'
	 when created_date = 18 then '18'
	 when created_date = 19 then '19'
	 when created_date = 20 then '20'
	 when created_date = 21 then '21'
	 when created_date = 22 then '22'
	 when created_date = 23 then '23'
	 when created_date = 24 then '24'
	 when created_date = 25 then '25'
	 when created_date = 26 then '26'
	 when created_date = 27 then '27'
	 when created_date = 28 then '28'
	 when created_date = 29 then '29'
	 when created_date = 30 then '30'
	 when created_date = 31 then '31'
	 end;




alter table Global_YouTube_Earnings
add conc_year_month varchar (50)


update Global_YouTube_Earnings
set conc_year_month = CONCAT (created_year, '-', created_month_num)


alter table Global_YouTube_Earnings
add ch_creation_date varchar (50) 


update Global_YouTube_Earnings
set ch_creation_date = concat(conc_year_month, '-', created_date_new) 



select distinct ch_creation_date
from Global_YouTube_Earnings



select count(ch_creation_date)
from Global_YouTube_Earnings
where ch_creation_date = '--'


delete from Global_YouTube_Earnings
where ch_creation_date = '--'


select count(ch_creation_date)
from Global_YouTube_Earnings
where ch_creation_date = '1970-01-01'


delete from Global_YouTube_Earnings
where ch_creation_date = '1970-01-01'



Select conc_day_month_year, CONVERT(date, left(ch_creation_date,4) + substring(ch_creation_date, 6, 2) + right(ch_creation_date,2),103)
from Global_YouTube_Earnings



alter table dbo.Global_YouTube_Earnings
add creation_date date



update dbo.Global_YouTube_Earnings
set creation_date = CONVERT(date, left(ch_creation_date,4) + substring(ch_creation_date, 6, 2) + right(ch_creation_date,2),103)

 


select creation_date
from dbo.Global_YouTube_Earnings
where creation_date > '2021-08-11'


-- Removing null values 

select count (video_views)
from dbo.Global_YouTube_Subscriptions
where video_views = 0


delete from dbo.Global_YouTube_Subscriptions
where video_views = 0


select distinct category
from dbo.Global_YouTube_Subscriptions


select count (category)
from dbo.Global_YouTube_Subscriptions
where category = 'nan'


delete from dbo.Global_YouTube_Subscriptions
where category = 'nan'


select count (Country) 
from dbo.Global_YouTube_Earnings
where Country = 'nan'


delete from dbo.Global_YouTube_Earnings
where Country = 'nan'


select distinct country
from dbo.Global_YouTube_Earnings


-- Uploads, subscribers, views, youtubers grouped by continent


select distint Country
from dbo.Global_YouTube_Earnings


WITH CTE_continents as
(SELECT
 earn.Country,
 case
     when  earn.Country in ('Egypt','Morocco') then 'Africa'

     when  earn.Country in ('Andorra','Finland','France','Germany','Italy','Latvia','Netherlands','Spain','Sweden','Switzerland','Turkey',
         'Ukraine','United Kingdom') then 'Europe'

     when  earn.Country in ('Afghanistan','Bangladesh','China','India','Indonesia','Iraq','Japan','Jordan','Kuwait','Malaysia','Pakistan',
	    'Philippines','Russia','Saudi Arabia','Singapore','South Korea','Thailand','United Arab Emirates','Vietnam') then 'Asia'

     when  earn.Country in ('Barbados','Canada','Cuba','El Salvador','Mexico','United States') then 'North_America'

     when  earn.Country in ('Argentina','Brazil','Chile','Colombia','Ecuador','Peru','Venezuela') then 'South_America'

     when  earn.Country in ('Australia','Samoa') then 'Australia_and_Oceania '
	 end as Continent, 
subs.subscribers, earn.uploads, subs.video_views, subs.Youtuber
from dbo.Global_YouTube_Earnings earn
join dbo.Global_YouTube_Subscriptions subs 
on earn.Title = subs.Youtuber)
select Continent, round(sum(subscribers)/1000000,0) as million_subs,sum(uploads) as total_uploads,
                  round(sum(video_views)/1000000,0) as million_views,count(Youtuber) as num_of_youtubers
from CTE_continents
Group by Continent
Order by Continent



-- Top 10 countries for subscribers using Temp Table

drop table if exists #Temp_country_subs
create table #Temp_country_subs (
Country nvarchar(255),
Subscribers float)

insert into #Temp_country_subs
select earn.Country, sum(subs.subscribers) as country_total_subs
from dbo.Global_YouTube_Subscriptions subs 
join dbo.Global_YouTube_Earnings earn
on earn.Title = subs.Youtuber
group by earn.Country


select top (10) Country, Subscribers
from #Temp_country_subs
order by Subscribers desc


-- Top 8 categories by million views 


select distinct channel_type
from dbo.Global_YouTube_Earnings


select distinct category
from dbo.Global_YouTube_Subscriptions


with CTE_Global_Views as(
select category, round(sum(video_views)/1000000,0) as million_views
from dbo.Global_YouTube_Subscriptions
group by category)
select top (8) *
from CTE_Global_Views
order by 2 desc


-- Total Earnings percentage for every continent

with CTE_Earnings_Percent as (select Country,
 case
     when  Country in ('Egypt','Morocco') then 'Africa'

     when  Country in ('Andorra','Finland','France','Germany','Italy','Latvia','Netherlands','Spain','Sweden','Switzerland','Turkey',
         'Ukraine','United Kingdom') then 'Europe'

     when  Country in ('Afghanistan','Bangladesh','China','India','Indonesia','Iraq','Japan','Jordan','Kuwait','Malaysia','Pakistan',
	    'Philippines','Russia','Saudi Arabia','Singapore','South Korea','Thailand','United Arab Emirates','Vietnam') then 'Asia'

     when  Country in ('Barbados','Canada','Cuba','El Salvador','Mexico','United States') then 'North_America'

     when  Country in ('Argentina','Brazil','Chile','Colombia','Ecuador','Peru','Venezuela') then 'South_America'

     when  Country in ('Australia','Samoa') then 'Australia_and_Oceania '
	 end as Continent, 
	 highest_yearly_earnings/sum(highest_yearly_earnings) over ()*100 as Earnings_Percentage_Country 
from dbo.Global_YouTube_Earnings)
select Continent, round(sum(Earnings_Percentage_Country),2) as Earnings_Percentage_Continent
from CTE_Earnings_Percent
group by Continent


-- Views by every country (for choropleth map)

select earn.Country, sum(subs.video_views) as Views_by_Country
from dbo.Global_YouTube_Earnings earn
join  dbo.Global_YouTube_Subscriptions subs 
on earn.Title = subs.Youtuber
group by Country
order by 2 desc


-- Eliminating redundant columns

alter table Global_YouTube_Earnings
drop column created_month_num;


alter table Global_YouTube_Earnings
drop column conc_year_month;


alter table Global_YouTube_Earnings
drop column ch_creation_date;


alter table Global_YouTube_Earnings
drop column created_date_new;
