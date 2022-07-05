SELECT *
FROM PortfolioProject..coviddeath
Order by 3,4

--SELECT *
--FROM PortfolioProject..Covidvaccination
--Order by 3,4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeath
Order by 1,2

--Looking at total cases vs total Death

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeath
Where location like '%india%'
Order by 1,2

--Looking at total cases vs population


SELECT location, date, total_cases, population , (total_cases/population)*100 AS InfectedPercentPopulation
FROM PortfolioProject..coviddeath
Where location like '%india%'
Order by 1,2

-- Countries with highest infection rate compared to population

Select location, population , MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPoluationInfected
From PortfolioProject..coviddeath
--Where location like '%india%'
Group by location, population
Order by PercentPoluationInfected  desc

--Countries with Highest deathcount per Population

--Breaking things with continent

Select location, MAX (cast(total_deaths as int)) AS TotalDeathCount
--Where location like '%india%'
from PortfolioProject..coviddeath
where continent is null
Group by location
order by TotalDeathCount desc

--Continents with the Highest Death Count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeath
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount  desc

--Global Numbers

select   SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..coviddeath
where continent is not null
--group by date
order by 1,2


--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

with PopvsVac ( Continent, Location, Date, Population, New_Vacciantions, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccination vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 --order by 2,3 
	 )
	 select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
 Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
insert into  #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccination vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 --order by 2,3 
	select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- To view  PercentPopulationVaccinated for the final viz

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccination vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	-- order by 2,3 

	select *
	from PercentPopulationVaccinated