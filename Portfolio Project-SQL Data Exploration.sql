Select*
From PortfolioProject..CovidDeaths
Order by 3,4

Select*
From PortfolioProject..CovidVaccinations
Order by 3,4

----Select data to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

----Total Cases VS Total Deaths
----Shows likelihood of dying from covid in Nigeria

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'
Order by 1,2

---Total Cases VS Population
---Shows what percentage of the population got infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'
Order by 1,2

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
---Where location like '%Nigeria%'
Order by 1,2


----Countries with the highest infection rate compared to the population
Select location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
---Where location like '%Nigeria%'
Group by location, population
Order by PercentagePopulationInfected desc

---Countries with highest death count per population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
---Where location like '%Nigeria%'
Where Continent is not null
Group by location
Order by TotalDeathCount desc

----BREAK DOWN BY CONTINENT
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
---Where location like '%Nigeria%'
Where Continent is null
Group by location
Order by TotalDeathCount desc

----Continent with highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
---Where location like '%Nigeria%'
Where Continent is not null
Group by continent
Order by TotalDeathCount desc

---Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
---Where location like '%Nigeria%'
Where continent IS NOT NULL
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
---Where location like '%Nigeria%'
Where continent IS NOT NULL
---Group by date
Order by 1,2

Select * From CovidVaccinations

-----Joining the deaths and vacinnations table to see Total population vs vaccinations
Select* from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations  ----check when Nigeria started vaccinations
from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  ----check when Nigeria started vaccinations
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CummulativePeopleVaccinated
---(CummulativePeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3

---USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, CummulativePeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  ----check when Nigeria started vaccinations
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CummulativePeopleVaccinated
---(CummulativePeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
---Order by 2,3
)
Select*
From PopvsVac

with PopvsVac (continent, location, date, population, new_vaccinations, CummulativePeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  ----check when Nigeria started vaccinations
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CummulativePeopleVaccinated
---(CummulativePeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
---Order by 2,3
)
Select*, (CummulativePeopleVaccinated/population)*100
From PopvsVac

--OR

---TEMP TABLE
 
 DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 CummulativePeopleVaccinated numeric,
 )
 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CummulativePeopleVaccinated
---(CummulativePeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
---Where dea.continent is not null
---Order by 2,3
Select*, (CummulativePeopleVaccinated/population)*100
From #PercentPopulationVaccinated


----CREATE VIEW FOR VISUALIZATIONS

CREATE view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CummulativePeopleVaccinated
---(CummulativePeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
----Order by 2,3


Select *
From PercentPopulationVaccinated