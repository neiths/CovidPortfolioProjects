--select data
Select *
from PortfolioProject..CovidVaccinations
order by 3,4

Select *
from PortfolioProject..CovidDeaths

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Nam'
order by 1,2

-- looking at total cases vs population
-- Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as GotCovidPercentage
from PortfolioProject..CovidDeaths
--where location like '%Nam'
order by 1,2

-- looking at countries with highest infected rate compared to population
Select location, population, Max(total_cases) as highestInfectedCount, Max((total_cases/population))*100 as GotCovidPercentage
from PortfolioProject..CovidDeaths
--where location like '%Nam'
group by location, population
order by GotCovidPercentage desc

-- Showing countries with highest death count per population
-- using cast(--- as int) 
-- total_deaths(nvarchar255) in data
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null --because in data, in column location. it grouped by rows
group by location
order by TotalDeathCount desc

-- let's break things down by continent
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null --because in data, in column location. it grouped by rows
group by continent
order by TotalDeathCount desc

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null --because in data, in column location. it grouped by rows
group by location
order by TotalDeathCount desc

-- global numbers
select date, sum(new_cases), sum(cast(total_deaths as int))
from PortfolioProject..CovidDeaths
where continent is not null --because in data, in column location. it grouped by rows
group by date
order by 1,2

-- looking at total population vs vaccinations
select *
from PortfolioProject..CovidVaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and dea.location ='VietNam'
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) over (partition by dea.location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 -->error --> use cte
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--use CTE
with PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) over (partition by dea.location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 -->error --> use cte
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
 
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac
order by 2,3

-- Tempt Table
--DROP Table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
) 
Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) over (partition by dea.location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 -->error --> use cte
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, (rollingPeopleVaccinated/population)*100 
from #percentpopulationvaccinated
where location = 'VietNam'
order by 2,3


--create view to store data for later visualizations
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) over (partition by dea.location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from percentpopulationvaccinated