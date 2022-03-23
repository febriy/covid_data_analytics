/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

--SELECT location, date, total_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of death if you contract COVID
--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as DeathPercentage
--FROM PortfolioProject..CovidDeaths
--where location like '%states%'
--order by 1,2

-- Looking at total cases vs population
--SELECT location, date, total_cases, Population, (total_cases/Population*100) as InfectedPercentage
--FROM PortfolioProject..CovidDeaths
--where location like '%singapore%'
--order by 1,2

-- Looking at countries with highest infection rate
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/Population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location like '%singapore%'
Group by location, population 
order by InfectedPercentage desc

-- Looking at countries with highest death/pop
SELECT location, Population, MAX(cast(total_deaths as int)) as HighestDeathCount, Max(total_deaths/Population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location like '%singapore%'
Group by location, population 
order by HighestDeathCount desc

-- Break down by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent 
order by TotalDeathCount desc

-- Break down by continent; death/pop
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent 
order by TotalDeathCount desc


-- GLOBAL NUMBER
SELECT date, SUM(new_cases) as total_cases, SUM(cast(total_deaths as int)) as total_deaths, SUM(cast(total_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- where location like '%singapore%'
where continent is not null
Group by date
order by 1,2

-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE (Common Table Expression) https://www.sqlshack.com/sql-server-common-table-expressions-cte/
With PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * ,( RollingPeopleVaccinated/population*100 )
From PopvsVac
order by 2,3

-- temp table
DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * ,( RollingPeopleVaccinated/population*100 )
From #PercentPopulationVaccinated

-- Create View for visualisation
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated