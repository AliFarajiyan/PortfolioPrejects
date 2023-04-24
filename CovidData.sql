Select *
from Portfolio_Project..covidDeaths
order by 3, 4

select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..covidDeaths
order by 1, 2

-- Total Cases VS Total deaths

select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 As DeathPercentage
from Portfolio_Project..covidDeaths
where continent is not null
order by 1, 2

-- Total Cases VS Population

select Location, date, Population, total_cases, (total_cases/Population)*100 As PercentPopulationInfected
from Portfolio_Project..covidDeaths
order by 1, 2

-- Countries with highest Infection Rate Compared to Population

select Location, Population, Max(total_cases) As HighestInfectionCount, MAX((total_cases/Population))*100 As PercentPopulationInfected
from Portfolio_Project..covidDeaths
group by location, population
order by PercentPopulationInfected Desc

-- Showing countries with highest Death Count Per Population

select Location, MAX(cast(total_deaths as int)) As TotalDeathCount
from Portfolio_Project..covidDeaths
where Continent is not null
group by location
order by TotalDeathCount Desc

-- Break things Down by Continent

select Continent, MAX(cast(total_deaths as int)) As TotalDeathCount
from Portfolio_Project..covidDeaths
where Continent is not null
group by Continent
order by TotalDeathCount Desc

-- Showing Continents with the highest death Count Per Population

select Continent, MAX(cast(total_deaths as int)) As TotalDeathCount
from Portfolio_Project..CovidDeaths
where Continent is not null
group by Continent
order by TotalDeathCount Desc

-- Global Numbers

select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths , 
Sum(cast(new_deaths as int))/Sum(new_cases) *100 As deathPercentage
from Portfolio_Project..covidDeaths
where continent is not null
order by 1, 2

-- Total population Vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE

with Popvsvac(continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from Popvsvac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Create view to store data for later Visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
