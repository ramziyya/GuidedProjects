SELECT *
FROM [Portfolio Project]..CovidDeaths
ORDER BY 3,4


SELECT *
FROM [Portfolio Project]..CovidVaccinations
ORDER BY 3,4

--Selecting data that is going to be using

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
From [Portfolio Project]..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

SELECT 
	location, 
	date, 
	total_cases,
	new_cases, 
	total_deaths, 
	(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 
	as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

select *
from [Portfolio Project]..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using\

select
	location,
	date, 
	total_cases,
	new_cases, 
	total_deaths, 
	population
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
 
select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100
	as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%baijan%'
order by 1,2

-- Looking at Total Cases vs Population
-- Which Percentage of Population got Covid
select 
	location, 
	date,
	Population, 
	total_cases, 
	new_cases, 
	(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 
	as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%baijan%'
where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population

select 
	location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount, 
	MAX((NULLIF(CONVERT(float, total_cases), 0)/population))*100 
	as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
group by location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select 
	location, 
	Population, 
	date,
	MAX(total_cases) as HighestInfectionCount, 
	MAX((NULLIF(CONVERT(float, total_cases), 0)/population))*100 
	as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location, Population, date
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population

select
	location,
	MAX(cast(total_deaths as float)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing continents with Highest Death Count per Population

select 
	continent, 
	MAX(cast(total_deaths as float)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


select 
	continent, 
	SUM(cast(new_deaths as float)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
and location not in('World','European Union', 'International')
group by continent
order by TotalDeathCount desc

-- Global Numbers

select  
	sum(NULLIF(CONVERT(float, new_cases),0)) as total_cases, 
	sum(NULLIF(CONVERT(float,new_deaths),0)) as total_deaths, 
	sum(NULLIF(CONVERT(float, new_deaths),0))/sum(NULLIF(CONVERT(float, new_cases),0)) as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	cast(vac.new_vaccinations as float), 
	sum(CONVERT(float,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3



with Popvsvac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	cast(vac.new_vaccinations as float), 
	sum(cast(vac.new_vaccinations as float)) 
over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
     on dea.location = vac.location
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 
from Popvsvac

-- Creating Temp Table

Drop Table if exists #PercentPeopleVaccinated 
Create table #PercentPeopleVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccination numeric,
	RollingPeopleVaccinated numeric
	)

insert into #PercentPeopleVaccinated
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	cast(vac.new_vaccinations as float), 
	sum(cast(vac.new_vaccinations as float)) 
over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPeopleVaccinated

-- Creating View to Store Data for Further Visualizations

create view PercentPeopleVaccinated as
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as float)) 
over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
from PercentPeopleVaccinated
