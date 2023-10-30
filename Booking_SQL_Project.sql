select *
from dbo.europe_hotels;


-- Renaming columns having a space instead than a underscore

sp_rename 'dbo.europe_hotels.Hotel name', 'Hotel_name'

sp_rename 'dbo.europe_hotels.Region city', 'Region_City'

sp_rename 'dbo.europe_hotels.Guests reviews:', 'Guests_reviews'


-- Splitting Region_City column into two: one containing the Region and the other the city

select parsename(replace(Region_City,',','.'),2) as Region,
parsename(replace(Region_City,',','.'),1) as City
from dbo.europe_hotels;


alter table dbo.europe_hotels
add Region varchar(255)


update dbo.europe_hotels
set Region = parsename(replace(Region_City,',','.'),2);


alter table dbo.europe_hotels
add City varchar(255)


update dbo.europe_hotels
set City = parsename(replace(Region_City,',','.'),1);


-- Removing spaces from City column

update dbo.europe_hotels
set City = trim(City)


-- Updating Region_City column where city is Paris (two commas were separating region from city), 
-- so that the region will appear in the new Region Column

select Region_City
from dbo.europe_hotels
where Region_City like '%Paris'



select parsename(replace(Region_City,',',''),2)
from dbo.europe_hotels
where Region_City like '%Paris'



update dbo.europe_hotels
set Region = parsename(replace(Region_City,',',''),2)
where Region_City like '%Paris'


select Region_City, Region, City
from dbo.europe_hotels
where Region_City like '%Paris';


-- Creating a new column to convert reviews column to integer

select replace(replace(replace(replace(Reviews,',',''),'reviews',''),'review',''),' external','')
from dbo.europe_hotels


alter table dbo.europe_hotels
add Reviews_Amount int


update dbo.europe_hotels
set Reviews_Amount = cast(replace(replace(replace(replace(Reviews,',',''),'reviews',''),'review',''),' external','') as int)  
from dbo.europe_hotels


-- Splitting Price column into two: one showing the original price, while the other the discounted one. 
-- Converting currency from zloty to eur


select Price,replace(replace(replace(substring(Price,1,charindex('zl',Price)-1),'Price ',''),'Original ',''),',','')
from dbo.europe_hotels


alter table dbo.europe_hotels
add Original_Price int


update dbo.europe_hotels
set Original_Price = replace(replace(replace(substring(Price,1,charindex('zl',Price)-1),'Price ',''),'Original ',''),',','')
from dbo.europe_hotels 


alter table dbo.europe_hotels
add Discounted_price int



with CTE_current_price as(
select replace(replace(replace(SUBSTRING(Price,Charindex('Current',Price)+14,5),'zl',''),',',''),'.','') as current_price,
Discounted_price
from(
select Price, Discounted_price
from dbo.europe_hotels
where charindex('Original',Price) > 0) as subquery_price)
update CTE_current_price
set Discounted_price = CTE_current_price.current_price


update dbo.europe_hotels
set Original_Price = Original_Price*0.22


update dbo.europe_hotels
set Discounted_price = Discounted_price*0.22

-- Creating a new column showing distance from the center in kms

alter table dbo.europe_hotels
add kms_from_center float


update dbo.europe_hotels
set kms_from_center = replace(Distances,' m from center','')
from dbo.europe_hotels
where Distances not like '%km from center'


update dbo.europe_hotels
set kms_from_center = kms_from_center/1000


update dbo.europe_hotels
set kms_from_center = replace(Distances,' km from center','')
where Distances like '%km from center'


select kms_from_center,Distances
from dbo.europe_hotels 

-- Creating a new column showing mark given to location

select distinct Guests_reviews
from dbo.europe_hotels


alter table dbo.europe_hotels
add Location_Mark float


select replace(Guests_reviews,'Location ','')
FROM dbo.europe_hotels


update dbo.europe_hotels
set Location_Mark = replace(Guests_reviews,'Location ','')
FROM dbo.europe_hotels 


select Guests_reviews, Location_Mark
from dbo.europe_hotels


-- Removing marks from performances and uniforming that column

select performances, count(performances) 
from dbo.europe_hotels
group by performances


select performances, marks
from dbo.europe_hotels
where Performances = 'Wonderful 9.0'


update dbo.europe_hotels
set Marks = 9.0
where Performances = 'Wonderful 9.0'


update dbo.europe_hotels
set Marks = 10
where Performances = 'Exceptional 10'


update dbo.europe_hotels
set Marks = 6.2
where Performances = 'Review Score 6.2'


alter table dbo.europe_hotels
add performances_unif nvarchar(255)


update dbo.europe_hotels
set performances_unif = replace(replace(replace(performances,' 9.0',''),' 6.2',''),' 10','')
from dbo.europe_hotels


select performances_unif,count (performances_unif)
from dbo.europe_hotels
group by performances_unif



-- Checking if there are any duplicate rows and removing them

with Duplicate_CTE as(
select *,
ROW_NUMBER () over (partition by Hotel_name, Marks, Region_City, Performances, Reviews, Price,Distances,
                    Discriptions, Stars, Breakfast,Guests_reviews order by Hotel_name) as row_num
from dbo.europe_hotels)
delete 
from Duplicate_CTE
where row_num > 1


select *
from dbo.europe_hotels
where Hotel_name like '%...'


-- Calculating percentage for performance type


with CTE_Performance_percent as(
select performances_unif, count_performances, sum (count_performances) over () as sum_count
from(
select performances_unif, count(performances_unif) as count_performances 
from dbo.europe_hotels
where performances_unif is not null
group by performances_unif) as subquery
group by performances_unif, count_performances)
select performances_unif as performance, cast(((count_performances*1.0/sum_count)*100) as decimal (4,2)) as percentage
from CTE_Performance_percent
group by performances_unif, count_performances, sum_count

-- Checking top and bottom 5 cities for marks

select top (5) city, cast(avg(Marks)as decimal (4,2)) as Average_Mark
from dbo.europe_hotels
group by city
order by Average_Mark desc


select top (5) city, cast(avg(Marks)as decimal (4,2)) as Average_Mark
from dbo.europe_hotels
group by city
order by Average_Mark 


-- Checking top 5 Regions for average price

select top 5 Region + ', ' + City as Region, avg(Original_Price) as Average_Price
from dbo.europe_hotels
group by Region,City
order by avg_price desc

-- Checking top 5 most expensive hotels

select top 5 Hotel_name, avg(Original_Price) as Average_Price
from dbo.europe_hotels
group by Hotel_name,City
order by avg_price desc
 


-- Checking top 5 most reviewed hotels

select top 5 Hotel_name  + ', ' + City as Hotel, sum(Reviews_Amount) as Total_reviews
from dbo.europe_hotels
group by Hotel_name,City
order by Total_reviews desc

-- Checking correlations between marks, prices and other columns

select (avg(kms_from_center*Marks)-(avg(kms_from_center)*avg(Marks)))/(stdevp(kms_from_center)*STDEVP(Marks))
from dbo.europe_hotels


select (avg(Reviews_Amount*Marks)-(avg(Reviews_Amount)*avg(Marks)))/(stdevp(Reviews_Amount)*STDEVP(Marks))
from dbo.europe_hotels


select (avg(Reviews_Amount*Original_Price)-(avg(Reviews_Amount)*avg(Original_Price)))/(stdevp(Original_Price)*STDEVP(Reviews_Amount))
from dbo.europe_hotels


select (avg(kms_from_center*Discounted_price)-(avg(kms_from_center)*avg(Discounted_price)))/(stdevp(Discounted_price)*STDEVP(kms_from_center))
from dbo.europe_hotels


-- Checking the average mark with and different meals combinations

select case
       when breakfast is null then 'No meals included'
	   else breakfast
	   end as Meal_Plan, round(avg(marks),2) Average_Mark
from dbo.europe_hotels
group by breakfast
order by Average_Mark desc

-- Checking average price for city for choropleth mark

select city + Region, avg(Original_Price) as Average_Price
from dbo.europe_hotels
group by city, Region
order by Average_Price desc

-- Checking total reviews, total cities and hotels for card 

select sum(Reviews_Amount) as Total_Reviews
from dbo.europe_hotels



with CTE_Cities as(
select 
ROW_NUMBER () over (partition by City order by City) as row_num
from dbo.europe_hotels)
select sum(row_num) as Total_Cities
from CTE_Cities
where row_num = 1



with CTE_Hotels as(
select 
ROW_NUMBER () over (partition by Hotel_name order by Hotel_name) as row_num
from dbo.europe_hotels)
select sum(row_num) as Total_Hotels
from CTE_Hotels
where row_num = 1


-- Checking most expensive offers

select top 8 Discriptions as Offers, City, avg(Original_Price) as Average_price
from dbo.europe_hotels
group by Discriptions, City
order by average_price desc


-- Checking top 5 cities with biggest discounts

with CTE_Discount as(
Select City, Original_Price,Discounted_Price
from dbo.europe_hotels
where Discounted_Price is not null)
select top (5) city, cast(avg(((((Original_Price - Discounted_Price)*(1.0))/Original_Price)*100)) as decimal (4,2)) as Discount_Percentage
from CTE_Discount
group by City
order by Discount_Percentage desc

-- Checking how many hotels are discounted over total

select count(Hotel_Name) as Total_Hotels, COUNT(CASE WHEN Discounted_price is null THEN 1 END) AS Undiscounted_Hotels, 
COUNT(CASE WHEN Discounted_price is not null THEN 1 END) AS Discounted_Hotels,
cast((COUNT(CASE WHEN Discounted_price is not null THEN 1 END)*1.0 / COUNT(Hotel_Name) * 100) as decimal (4,2)) AS Percentage
from dbo.europe_hotels

-- Dropping redudant columns

Alter table dbo.europe_hotels
drop column Reviews


Alter table dbo.europe_hotels
drop column Price


Alter table dbo.europe_hotels
drop column Distances


Alter table dbo.europe_hotels
drop column Guests_reviews

