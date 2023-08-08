-------------PROJECT Queries-----------
select * 
from ['covid-deaths$']
where continent is not null
order by 3,4

select * from ['covid-vaccination$']
order by 2 desc
select  location,total_cases,new_cases,population,total_deaths
from ['covid-deaths$']
-----Count of total deaths
SELECT location,COUNT(total_deaths) AS total_deaths
FROM ['covid-deaths$']
where continent is not null
GROUP BY location
ORDER BY total_deaths desc
--deleting world
DELETE FROM ['covid-deaths$']
WHERE  location='World'
----Count of total cases
select  location,count(total_cases) as total_cases ,count(total_deaths) as total_deaths
from ['covid-deaths$']
where continent is not null
GROUP BY location
order by 2,3 desc

--total cases vs total deaths
select  location,date,
total_cases ,total_deaths,(total_deaths/total_cases)*100 as Ratio_of_death_and_cases
from ['covid-deaths$']
where location ='Pakistan' and continent is not null
GROUP BY location,date,total_cases ,total_deaths

--- cases vs population( to find out the % of people infected)
select  location,date,total_cases ,population,(total_cases/population)*100 as Ratio_of_population_infected
from ['covid-deaths$']
where continent is not null

----- countries with highst infection rate or cases
select  location,max(total_cases) as highest_infection_count_per_country ,max((total_cases/population))*100 as Max_Ratio_of_population_infected_per_counttry
from ['covid-deaths$']
--where location ='Pakistan'
where continent is not null
group by location
order by highest_infection_count_per_country

-----countries with highest _death_rate
select  location,max(total_deaths) as highest_death_per_countries
from ['covid-deaths$']
where continent is not null
group by location
order by highest_death_per_countries desc

---Now break things based on continent 
--deaths
select continent,max(total_deaths) as total_deaths_per_continent from dbo.['covid-deaths$']
where continent is not null
group by continent
order by total_deaths_per_continent desc
 ---cases
 select continent,max(total_cases) as total_cases_per_continent from dbo.['covid-deaths$']
where continent is not null
group by continent
order by total_cases_per_continent desc
--cases vs death 
select  continent
total_cases ,total_deaths,(total_deaths/total_cases)*100 as Ratio_of_death_and_cases_per_continent
from ['covid-deaths$']
 where continent is not null
GROUP BY continent,total_cases ,total_deaths
order by Ratio_of_death_and_cases_per_continent desc

---now Global numbers
SELECT sum(new_deaths) as sum_of_new_deaths ,sum(new_cases) as sum_of_new_cases ,sum(new_deaths)/sum(new_cases)*100 as death_perecentage_globally
FROM ['covid-deaths$']
where continent is not null
order by 1,2

---looking fro total population vs vaccination
select death.continent,death.location,death.date,death.population,vac.new_vaccinations
,sum(convert(bigint,new_vaccinations)) over ( partition by death.location order by death.location,death.date) as sum_of_new_vaccination
from ['covid-deaths$'] death
join ['covid-vaccination$'] vac
on death.date=vac.date
and death.location=vac.location
where death.continent is not null
order by 2,3

----we can to use cte or temp table to get the percent of people vaccinated
with cte_pop_vs_vac (Continent,Location,date,Population,new_vaccinations,sum_of_new_vaccination)
as
(
select death.continent,death.location,death.date,death.population,vac.new_vaccinations
,sum(convert(bigint,new_vaccinations)) over ( partition by death.location order by death.location,death.date) as sum_of_new_vaccination
from ['covid-deaths$'] death
join ['covid-vaccination$'] vac
on death.date=vac.date
and death.location=vac.location
where death.continent is not null

---order by 2,3
)

select * ,(sum_of_new_vaccination/Population)*100 as perecentage_of_people_vaccinated 
from cte_pop_vs_vac
--using temp_table
drop table if exists #temp_vacc
 create table #temp_vacc
 (
 Continent  nvarchar(255),
 Location nvarchar(255) ,
 date datetime,
 Population float ,
 new_vaccination  nvarchar(255)   ,
 sum_of_new_vaccination numeric 

 )
 insert into #temp_vacc
select death.continent,death.location,death.date,death.population,vac.new_vaccinations
,sum(convert(bigint,new_vaccinations)) over ( partition by death.location order by death.location,death.date) as sum_of_new_vaccination
from ['covid-deaths$'] death
join ['covid-vaccination$'] vac
on death.date=vac.date
and death.location=vac.location
where death.continent is not null

  select *, (sum_of_new_vaccination/Population)*100 as perecentage_of_people_vaccinated 
from #temp_vacc

--creating  view to store data for later visualizations
create view temp_vacc
as
select death.continent,death.location,death.date,death.population,vac.new_vaccinations
,sum(convert(bigint,new_vaccinations)) over ( partition by death.location order by death.location,death.date) as sum_of_new_vaccination
from ['covid-deaths$'] death
join ['covid-vaccination$'] vac
on death.date=vac.date
and death.location=vac.location
where death.continent is not null

select * from #temp_vacc
-------------