-- Data exploration in SQL
-- Covid-19  Protfolio Project
SELECT * 
FROM Project..CovidDeaths$

SELECT * 
FROM Project..CovidVaccinations$

SELECT * 
FROM Project..CovidDeaths$
where continent is not null 
order by 3,4

SELECT * 
FROM Project..CovidVaccinations$
where continent is not null 
order by 3,4

--Select data that we are going to use

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM Project..CovidDeaths$
where continent is not null 
order by 1,2

-- Looking at the Total Cases Vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

Select Location,date,total_cases,total_deaths,(Total_deaths / Total_cases)*100 as DeathPercentage
FROM Project..CovidDeaths$
--where location like '%india%'
--where continent is not null 
order by 1,2

-- Looking total cases Vs Populations
-- shows what percentage of populations got covid

Select Location,date,population,total_cases,(Total_cases/population)*100 as Percentagepopulation
FROM Project..CovidDeaths$
--where location like '%india%'
where continent is not null 
order by 1,2

--Looking at the country having highest infection rate as compared to population.

Select Location,population,Max(total_cases) as HighestinfectionCount, max((Total_cases/population))*100 as Percentagepopulation
FROM Project..CovidDeaths$
--where location like '%india%'
where continent is not null 
Group by Location,population
order by Percentagepopulation desc

--Showing countries with highest death count per population

Select Location,Max(cast(total_deaths as int))as TotalDeathCount
FROM Project..CovidDeaths$
--where location like '%india%'
where continent is not null 
Group by Location
order by TotalDeathCount desc


--Lets break it into continents with highest deaths

Select continent,Max(cast(total_deaths as int))as TotalDeathCount
FROM Project..CovidDeaths$
--where location like '%india%'
where continent is not null 
Group by continent
order by TotalDeathCount desc


--showing continets with highest number of deaths count per populations

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) *100  as DeathPercentage
FROM Project..CovidDeaths$
--where location like '%india%'
where continent is not null 
group by date
order by 1,2

--Overall global numbers of covid Cases & deaths

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) *100  as DeathPercentage
FROM Project..CovidDeaths$
where continent is not null 
order by 1,2

-- Joining both tables

select*
From Project..CovidDeaths$ as dea
join Project..CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 4

--Looking for Total vaccinated people vs Total population

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date ) as vaccinations_record
From Project..CovidDeaths$ as dea
join Project..CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--CTE method

with popvsvacc (continent,location,date,population,new_vaccinations,vaccinations_record)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date ) as vaccinations_record
From Project..CovidDeaths$ as dea
join Project..CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select* ,(vaccinations_record/population)*100 as vaccinated_percentage
from popvsvacc

-- Temp Table 
Drop table if exists  populationvsvaccinations
Create table populationvsvaccinations
(
continent nvarchar (250),
location nvarchar (250),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinations_record numeric)
insert into populationvsvaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date ) as vaccinations_record
From Project..CovidDeaths$ as dea
join Project..CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select*, (vaccinations_record/population)*100 as vaccinated_percentage
from populationvsvaccinations

--Create View 
Create view percentagepopulationvsvaccinations as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date ) as vaccinations_record
From Project..CovidDeaths$ as dea
join Project..CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3