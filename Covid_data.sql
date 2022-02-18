-- This project is based on Global data on confirmed Covid-19 deaths and Vaccination drives. 
-- The data is taken from Ourworldindata.org and the project is focused on Exploratory data analysis. For the purpose of this project,
-- I've Divided the dataset into two tables Covid_deaths and Covid_vaccinations and will be exploring these two tables and also performing JOIN functions to Join them for Combine analysis.

-- Checking Covid_deaths Dataset
SELECT *
FROM Covid_19..Covid_deaths
ORDER BY 3,4
-- Checking Covid_Vaccinations Dataset 
SELECT *
FROM Covid_19..Covid_vaccinations
ORDER BY 3,4

-- Select data that is going to be used
SELECT location, date, population, total_cases, total_deaths
FROM Covid_19..Covid_deaths
ORDER BY 1,2

-- Looking at total cases VS total deaths in India
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Covid_19..Covid_deaths
WHERE location = 'India'
ORDER BY 1,2
--Data shows India has comparitively low percentage of deaths over total cases than other countries

-- Looking at Population VS total Cases in India
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Covid_19..Covid_deaths
WHERE location = 'India'
ORDER BY 1,2

-- Looking at Population VS total Cases with percent total cases increase by date
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Total_cases_percentage
FROM Covid_19..Covid_deaths
WHERE location = 'India'
ORDER BY 1,2

-- Global rate
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Total_cases_percentage
FROM Covid_19..Covid_deaths
ORDER BY 1,2
-- Data shows despite of having larger population, the percentage of population that got covid is low as compared to other countries 

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX (total_cases) AS max_infection_count , MAX (total_cases/population)*100 AS infection_percentage
FROM Covid_19..Covid_deaths
GROUP BY location, population 
ORDER BY infection_percentage desc

-- Looking at countries with higest death count 
SELECT location, population, MAX (CAST(total_deaths as int)) AS total_death_count, MAX (total_deaths/population)*100 AS death_percentage 
FROM Covid_19..Covid_deaths
WHERE continent is not null
GROUP BY location, population 
ORDER BY total_death_count desc

-- countries with highest death percent to population
SELECT location, population, MAX (CAST(total_deaths as int)) AS total_death_count, MAX (total_deaths/population)*100 AS death_percentage 
FROM Covid_19..Covid_deaths
WHERE continent is not null
GROUP BY location, population 
ORDER BY death_percentage desc

-- Looking at death rate by continent

SELECT continent, MAX (CAST(total_deaths as int)) AS total_death_count, MAX (total_deaths/population)*100 AS death_percentage 
FROM Covid_19..Covid_deaths
WHERE continent is not null
GROUP BY continent 
ORDER BY death_percentage desc

-- where continent is null 
SELECT location, continent, MAX (CAST(total_deaths as int)) AS total_death_count 
FROM Covid_19..Covid_deaths
WHERE continent is null 
GROUP BY location, continent 
ORDER BY total_death_count desc

-- When you don't want Income groups to be counted in locations

SELECT location, continent, MAX (CAST(total_deaths as int)) AS total_death_count 
FROM Covid_19..Covid_deaths
WHERE continent is null AND location IN ('World', 'Europe', 'North America', 'Asia', 'South America', 'European Union', 'Africa',
'Oceania')
GROUP BY location, continent 
ORDER BY total_death_count desc

--Let's look at max deaths VS birth rate by location

SELECT location, MAX (total_deaths/population)*100 as death_rate, MAX (reproduction_rate) as max_repro_rate
FROM Covid_19..Covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY 1,2

-- Death rate VS birth rate by continent
SELECT continent, MAX (total_deaths/population)*100 as death_rate, MAX (reproduction_rate) as max_repro_rate
FROM Covid_19..Covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY 1,2

-- Death rate VS birth rate in India
SELECT location, MAX (total_deaths/population)*100 as death_rate, MAX (reproduction_rate) as max_repro_rate
FROM Covid_19..Covid_deaths
WHERE location = 'India'
GROUP BY location
ORDER BY 1,2


-- Global numbers
SELECT date, SUM (new_cases) as total_cases, SUM (CAST (new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/ SUM(new_cases)*100 AS death_percentage 
FROM Covid_19..Covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total cases vs death percentage
SELECT SUM (new_cases) as total_cases, SUM (CAST (new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/ SUM(new_cases)*100 AS death_percentage 
FROM Covid_19..Covid_deaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- CHECKING OUT COVID_VACCINATION DATASET

SELECT *
FROM Covid_19..Covid_vaccinations
ORDER BY 3,4

-- JOIN COVID DEATHS AND COVID VACCINATION
SELECT *
FROM Covid_19..Covid_deaths dea
JOIN Covid_19..Covid_vaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
      

-- LOOKING AT TOTAL POPULATION VS TOTAL VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Covid_19..Covid_deaths dea
JOIN Covid_19..Covid_vaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- To get the total vaccinations without adding the column for total vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations))
          OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		  , RollingPeopleVaccinated/population)*100
FROM Covid_19..Covid_deaths dea
JOIN Covid_19..Covid_vaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- As we can't use the column we did'nt even created yet, so we will use COMMON TABLE EXPRESSION (CTE)

WITH popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) AS RollingPeopleVaccinated
		 -- , RollingPeopleVaccinated/population)*100
FROM Covid_19..Covid_deaths dea
JOIN Covid_19..Covid_vaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvac

-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) AS RollingPeopleVaccinated
		 -- , RollingPeopleVaccinated/population)*100
FROM Covid_19..Covid_deaths dea
JOIN Covid_19..Covid_vaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Suppose you don't want the WHERE claus
-- In case of a temp table, if you want to do any alterations then you need to add the DROP TABLE IF EXISTS claus to avoid error

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) AS RollingPeopleVaccinated
		 -- , RollingPeopleVaccinated/population)*100
FROM Covid_19..Covid_deaths dea
JOIN Covid_19..Covid_vaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualisation

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) AS RollingPeopleVaccinated
		 -- , RollingPeopleVaccinated/population)*100
FROM Covid_19..Covid_deaths dea
JOIN Covid_19..Covid_vaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

-- Creating view of Covid death percentage by continent

create view continentwisedeathpercent as
SELECT continent, MAX (CAST(total_deaths as int)) AS total_death_count, MAX (total_deaths/population)*100 AS death_percentage 
FROM Covid_19..Covid_deaths
WHERE continent is not null
GROUP BY continent 
--ORDER BY death_percentage desc

SELECT *
FROM continentwisedeathpercent