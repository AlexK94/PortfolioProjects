

set language us_english;

-- show country table

select *
from  portfolio_project..tempcountry;


-- check how many countries in the country table

select Count (distinct country)
from portfolio_project..tempcountry;

-- 50 more than actual countries

-- check the countries

select country
from portfolio_project..tempcountry
group by country
order by 1;


-- continents are included and some european countries have duplicate entries that ends with (europe)

--check the duplicates


select *
from portfolio_project..tempcountry
where country like '%(Europe)';


-- check if the duplicates avg temperature has the same values


select a.country,
case
	when 
		ori_avg_temp = dup_avg_temp and 
		ori_avg_unce = dup_avg_unce then 'Same'
	else 
		'Different'
end 
from 
	(select country, avg(cast(averagetemperature as float)) as ori_avg_temp, avg(cast(averagetemperatureuncertainty as float)) as ori_avg_unce 
	from portfolio_project..tempcountry
	group by country) a
join
	(select country, avg(cast(averagetemperature as float)) as dup_avg_temp, avg(cast(averagetemperatureuncertainty as float)) as dup_avg_unce 
	from portfolio_project..tempcountry
	where country like '%(Europe)'
	group by country)  b
on a.country = replace(b.country, ' (Europe)', '');

-- check how big the difference


select a.country, ori_avg_temp - dup_avg_temp, ori_avg_unce - dup_avg_unce
	
from 
	(select country, avg(cast(averagetemperature as float)) as ori_avg_temp, avg(cast(averagetemperatureuncertainty as float)) as ori_avg_unce 
	from portfolio_project..tempcountry
	group by country) a
join
	(select country, avg(cast(averagetemperature as float)) as dup_avg_temp, avg(cast(averagetemperatureuncertainty as float)) as dup_avg_unce 
	from portfolio_project..tempcountry
	where country like '%(Europe)'
	group by country)  b
on a.country = replace(b.country, ' (Europe)', '');


-- Denmark has a really big difference in average temperature

select country, avg(cast(averagetemperature as float))
from portfolio_project..tempcountry
where country like 'Denmark%'
group by country;

-- Denmark (Europe) only the european part, Denmark without (Europe) includes also the autonmous territories Faroe Islands and Greenland -> because of that big temperature gap
-- So Countrys ending with (Europe) are not duplicates

-- country with the highest average temperature

select top 1 country, avg(cast(averagetemperature as float)) as avg_temp
from portfolio_project..tempcountry
group by country
order by avg_temp Desc;

-- country with the lowest temperature

select top 1 country, avg(cast(averagetemperature as float)) as avg_temp
from portfolio_project..tempcountry
where AverageTemperature is not null
group by country
order by avg_temp asc;

-- average temperatures by continent

select country, avg(cast(averagetemperature as float)) as avg_temp
from portfolio_project..tempcountry
where country = 'Asia' or country = 'Europe' or country = 'Africa' or country = 'Australia' or country like '%America'
group by country;


-- check the year where the data for germany is complete

select *
from portfolio_project..tempcountry
where country = 'Germany' and averageTemperature is null;

-- since 1753 until 2012

-- absolute and percentage difference in avg temperature from the first decade to the last 

select a.temp - b.temp abso, (a.temp/b.temp-1)*100 per, b.uncer, a.uncer
from 
	(select avg(cast(averagetemperature as float))  temp, avg(cast(AverageTemperatureUncertainty as float)) uncer
	from portfolio_project..tempcountry
	where year(dt) between 1760 and 1769 and country = 'Germany') b,
	(select avg(cast(averagetemperature as float))  temp, avg(cast(AverageTemperatureUncertainty as float)) uncer
	from portfolio_project..tempcountry
	where year(dt) between 2000 and 2009 and country = 'Germany') a

-- Germany temp by decade

select(floor(year(dt)/10)*10) as decade, avg(cast(averagetemperature as float))  temp, avg(cast(AverageTemperatureUncertainty as float)) uncer
from portfolio_project..tempcountry
where year(dt)>1759 and country = 'Germany'
group by floor(year(dt)/10)
order by floor(year(dt)/10);

-- Germany temp difference per year

select a.y, (a.temp/b.temp-1)*100, a.temp-b.temp
from 
	(select year(dt) as y, avg(cast(averagetemperature as float)) temp
	from portfolio_project..tempcountry
	where country ='Germany' and year(dt) between 1761 and 2012
	group by year(dt)) a
join
	(select year(dt) +1 as y, avg(cast(averagetemperature as float)) temp
	from portfolio_project..tempcountry
	where country = 'Germany'
	group by year(dt)+1) b
on a.y=b.y 
order by a.y;

-- check the year where the data for continents is complete

select year(dt)
from portfolio_project..tempcountry
where (country = 'Asia' or country = 'Europe' or country = 'Africa' or country = 'Australia' or country like '%America') and averageTemperature is null
group by year(dt)
order by year(dt);


--1867 till 2012 complete


-- absolute and percentage difference in avg temperature from the first decade to the last 

select a.country, a.temp - b.temp abso, (a.temp/b.temp-1)*100 per, b.uncer, a.uncer
from 
	(select country, avg(cast(averagetemperature as float))  temp, avg(cast(AverageTemperatureUncertainty as float)) uncer
	from portfolio_project..tempcountry
	where year(dt) between 1870 and 1879 and (country = 'Asia' or country = 'Europe' or country = 'Africa' or country = 'Australia' or country like '%America')
	group by country) b
join	
	(select country, avg(cast(averagetemperature as float))  temp, avg(cast(AverageTemperatureUncertainty as float)) uncer
	from portfolio_project..tempcountry
	where year(dt) between 2000 and 2009 and (country = 'Asia' or country = 'Europe' or country = 'Africa' or country = 'Australia' or country like '%America')
	group by country) a
on a.country = b.country


-- colder continents are more affected by climate change

-- continent temp by decade

select country,(floor(year(dt)/10)*10) as decade, avg(cast(averagetemperature as float))  temp, avg(cast(AverageTemperatureUncertainty as float)) uncer
from portfolio_project..tempcountry
where year(dt)>1867 and (country = 'Asia' or country = 'Europe' or country = 'Africa' or country = 'Australia' or country like '%America')
group by floor(year(dt)/10), country
order by country,floor(year(dt)/10);


-- find the country that is most affected by climate change
-- first check at what point the data is complete

select year(dt), Country
from portfolio_project..tempcountry
where  averageTemperature is null
group by country, year(dt)
order by year(dt);

-- since 1950 till 2012 only Antarctica has incomplete data

select a.country, a.temp - b.temp abso, (a.temp/b.temp-1)*100 per, b.uncer, a.uncer
from 
	(select country, avg(cast(averagetemperature as float))  temp, avg(cast(AverageTemperatureUncertainty as float)) uncer
	from portfolio_project..tempcountry
	where year(dt) between 1950 and 1959 and not country = 'Antarctica'
	group by country) b
join	
	(select country, avg(cast(averagetemperature as float))  temp, avg(cast(AverageTemperatureUncertainty as float)) uncer
	from portfolio_project..tempcountry
	where year(dt) between 2000 and 2009 and not country = 'Antarctica'
	group by country) a
on a.country = b.country
order by a.temp-b.temp desc


-- check global temperature table

select * 
from portfolio_project..temp;


-- average temperature difference from the first ten years to the last ten years 

select a.temp - b.temp abso, (a.temp/b.temp-1)*100 per, b.uncer, a.uncer
from 
	(select avg(cast(landaveragetemperature as float))  temp, avg(cast(landAverageTemperatureUncertainty as float)) uncer
	from portfolio_project..temp
	where year(dt) between 1753 and 1762) b,	
	(select avg(cast(landaveragetemperature as float))  temp, avg(cast(landAverageTemperatureUncertainty as float)) uncer
	from portfolio_project..temp
	where year(dt) between 2006 and 2015) a

-- month with the highest average temperature and uncertainty <1

select top 1 dt, landaveragetemperature, LandAverageTemperatureUncertainty
from portfolio_project..temp
where cast(landaveragetemperatureuncertainty as float) <1
order by cast(landaveragetemperature as float) desc 

-- year with the highest average temperature 

select top 1 year(dt), avg(cast(landaveragetemperature as float)), avg(cast(LandAverageTemperatureUncertainty as float))
from portfolio_project..temp
group by year(dt)
order by avg(cast(landaveragetemperature as float)) desc 


-- date with the highest land max temperature


select Top 1 dt, landmaxtemperature
from portfolio_project..temp
order by cast(landmaxtemperature as float) desc;

-- year with the highest land and ocean average temperature

select top 1 year(dt), avg(cast(landandoceanaveragetemperature as float)) as avglandocean
from portfolio_project..temp
group by year(dt)
order by avglandocean desc;