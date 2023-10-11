Select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths 
order by 1,2

--Total cases vs Total deaths
Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths 
order by 1,2

--Likelihood of dying if you contract covid in your country
Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths 
Where location like '%states%'
Order by 1,2

--Total cases vs population
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From CovidDeaths 
Where location like 'Kenya'
Order by 1,2

--Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths 
Group by location, population
Order by PercentPopulationInfected desc

--Countries with highest death count per to population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths 
Where continent is not null
Group by location 
Order by TotalDeathCount desc

--Breaking things down by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths 
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths 
Where continent is not null
Group by date
Order by 1,2


Select *
From CovidVaccinations

Select dea.continent, dea.location, dea.population, vac.new_vaccinations
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null 
Order by 1,2,3


--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null 
Order by 1,2,3


--Using CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null 
--Order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null 
--Order by 1,2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization
CREATE VIEW PercentPorpulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null 
--Order by 1,2,3