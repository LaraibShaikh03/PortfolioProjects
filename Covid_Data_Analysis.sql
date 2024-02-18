
SELECT * FROM PortfolioProject..CovidDeaths$

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1, 2

-- total cases vs total deaths
SELECT location, date, total_cases, total_deaths
From PortfolioProject..CovidDeaths$
where location like '%states'
order by 1, 2

-- percentage of population got covid
SELECT location, date, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths$
order by 1, 2

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths$
Group By location, population
order by PercentageOfPopulationInfected desc

-- countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group By location
order by TotalDeathCount desc

-- -- in the result of above query we get the data of locations that are actually group of countries within them 
-- hence we will fix this first.
SELECT * FROM PortfolioProject..CovidDeaths$
where continent is not null

-- continents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group By continent
order by TotalDeathCount desc

-- global numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
-- Group by date
order by 1, 2

-- total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeople_Vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- CTE
WITH PopulationVsVaccinations (continent, location, date,population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT * , (Rolling_People_Vaccinated/population)*100 as Percentage_Of_People_Vaccinated
FROM PopulationVsVaccinations

-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent is not null

SELECT * , (RollingPeopleVaccinated/population)*100 as Percentage_Of_People_Vaccinated
FROM #PercentPopulationVaccinated


-- Creating a view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPopulationVaccinated -- the data here is obtained from a view

