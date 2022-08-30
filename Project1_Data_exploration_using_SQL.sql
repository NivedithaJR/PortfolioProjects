SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [SQL Project Portfolio].dbo.Covid_Deaths
where continent IS NOT NULL
ORDER BY 1,2

--Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)* 100, 2) as percentage_deaths
FROM [SQL Project Portfolio].dbo.Covid_Deaths
WHERE location like '%states%' and  continent IS NOT NULL
ORDER BY 1,2

-- Total cases versus Population
SELECT location, date, total_cases, population, (total_cases/population)* 100 as percentage_population_infected
FROM [SQL Project Portfolio].dbo.Covid_Deaths
WHERE location like '%states%' and  continent IS NOT NULL
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as highest_infected_count,MAX((total_cases/population))* 100 as percentage_population_infected
FROM [SQL Project Portfolio].dbo.Covid_Deaths
WHERE  continent IS NOT NULL
GROUP BY location, population  
ORDER BY percentage_population_infected desc

--Countries with highest death count compared to population
SELECT location, population, MAX(cast(total_deaths as int)) as highest_totaldeath_count,MAX((cast(total_deaths as int)/population))* 100 as percentage_population_dead
FROM [SQL Project Portfolio].dbo.Covid_Deaths
WHERE  continent IS NOT NULL
GROUP BY location, population 
ORDER BY percentage_population_dead desc

--Continent with highest death count 
SELECT continent, MAX(total_death_by_continent) as max_deathcount_by_continent
FROM (SELECT DISTINCT continent, date, SUM(cast(total_deaths as int)) OVER (PARTITION BY continent, date) as total_death_by_continent
		FROM [SQL Project Portfolio].dbo.Covid_Deaths
		WHERE  continent IS NOT NULL
		) a
GROUP BY continent
order by max_deathcount_by_continent desc

--Global cases and deaths
SELECT SUM(new_cases) as total_cases , SUM(CAST(new_deaths as int))  as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as global_death_percentage  
FROM Covid_Deaths
WHERE continent IS NOT NULL



--Total population vs vaccination
SELECT SUM(d.population) as total_pop,SUM(CAST(v.total_vaccinations as bigint)) as total_vacc,  SUM(CAST(v.total_vaccinations as bigint)) /SUM(d.population) *100 as total_vac_vs_pop
FROM Covid_Deaths d
JOIN Covid_Vaccinations v
ON d.date = v.date AND d.location = v.location


--Rolling Sum of people vaccinated

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location , d.date) as rollingsum_ppl_vaccinated
FROM Covid_Deaths d
JOIN Covid_Vaccinations v
ON d.date = v.date AND d.location = v.location
WHERE d.continent is not null
ORDER BY d.location, d.date

--Rolling Sum of people vaccinated as fraction of population

WITH pop_vs_vac (continent, location, date, population, new_vaccinations,rollingsum_ppl_vaccinated )
AS
(SELECT  d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location , d.date) as rollingsum_ppl_vaccinated
FROM Covid_Deaths d
JOIN Covid_Vaccinations v
ON d.date = v.date AND d.location = v.location
WHERE d.continent is not null)

SELECT *,(rollingsum_ppl_vaccinated/population) *100 as percent_vaccinated_per_pop
FROM pop_vs_vac

--Using TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
rollingsum_ppl_vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated 
SELECT  d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS numeric)) OVER (PARTITION BY d.location ORDER BY d.location , d.date) as rollingsum_ppl_vaccinated
FROM [SQL Project Portfolio].dbo.Covid_Deaths d
JOIN [SQL Project Portfolio].dbo.Covid_Vaccinations v
ON d.date = v.date AND d.location = v.location
WHERE d.continent is not null

SELECT *, (rollingsum_ppl_vaccinated/population) *100 as percent_vaccinated_per_pop
FROM #PercentPopulationVaccinated 
 

 --Creating view for storing table and visualisation

 CREATE VIEW Continent_highest_Death_count as
 SELECT continent, MAX(total_death_by_continent) OVER (PARTITION BY continent) as max_deathcount_by_continent
FROM (SELECT DISTINCT continent, date, SUM(cast(total_deaths as int)) OVER (PARTITION BY continent, date) as total_death_by_continent
		FROM [SQL Project Portfolio].dbo.Covid_Deaths
		WHERE  continent IS NOT NULL
		) a


CREATE VIEW PercentPopulationVaccinated as
SELECT  d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS numeric)) OVER (PARTITION BY d.location ORDER BY d.location , d.date) as rollingsum_ppl_vaccinated
FROM [SQL Project Portfolio].dbo.Covid_Deaths d
JOIN [SQL Project Portfolio].dbo.Covid_Vaccinations v
ON d.date = v.date AND d.location = v.location
WHERE d.continent is not null

