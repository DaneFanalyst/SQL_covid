select * 
From Portfolio_Project..covid_death$
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
from Portfolio_Project..covid_death$
order by 1,2

-- looking at total cases vs total deaths
--Shows likelyhood of death by country
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/Total_cases)*100 as DeathPercentage
from Portfolio_Project..covid_death$
where location like '%states%'
order by 1,2

-- looking at total cases vs total population

Select Location, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 as infectionrate
from Portfolio_Project..covid_death$
where location like '%states%'
order by 1,2

--countires with highest infection rate

Select Location, population, Max(total_cases) as HighesInfection,
max((total_cases/population))*100 as PercentPopulationInfected
from Portfolio_Project..covid_death$
group by location, population
order by PercentPopulationInfected desc

-- Showing countries with Highest death count per capita

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..covid_death$
where continent is not null
group by location
order by TotalDeathCount desc

--By continent 
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..covid_death$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..covid_death$
Where continent is not null
Group by date
Order by 1,2

--joining second table, looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_death$ dea
join Portfolio_Project..covid_vac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccianted)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_death$ dea
join Portfolio_Project..covid_vac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccianted/population)*100
from PopvsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250), 
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_death$ dea
join Portfolio_Project..covid_vac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Making view for future viz projects
Use Portfolio_Project
go

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_death$ dea
join Portfolio_Project..covid_vac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

