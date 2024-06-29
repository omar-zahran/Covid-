-- Showing the data from (CovidDeaths) table

Select * 
FROM Covid..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY location


-- Showing the data from (CovidVaccinations) table
Select * 
FROM Covid..CovidVaccinations$
WHERE continent IS NOT NULL
ORDER BY location


-- Select the data that we will use

SELECT location, 
	   date, 
	   total_cases, 
	   new_cases, 
	   total_deaths,
	   population
From Covid..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total cases VS Total deaths & The percentage between them
-- Here is the The percentage of death in Egypt

SELECT location, 
	   date, 
	   total_cases, 
	   total_deaths, 
	   (total_deaths/total_cases)*100 AS The_percentage_of_death
From Covid..CovidDeaths$
WHERE location = 'Egypt'
AND continent IS NOT NULL


-- Total deaths VS Population & The percentage between them
-- Here is the The percentage of infected people in united states

SELECT location, 
	   format(date,'dd-MM-yyyy') AS Date, 
	   total_cases, 
	   population, 
	   (total_cases/population)*100 AS The_percentage_of_infected_people
From Covid..CovidDeaths$
WHERE location = 'united states'
AND continent IS NOT NULL


-- maximum infected percentage of each country

SELECT location, 
	   population, 
	   MAX(total_cases) AS maximum_infected_Cases, 
	   MAX((total_cases/population))*100 AS maximum_infected_percentage_of_each_country
From Covid..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location , population
ORDER BY maximum_infected_percentage_of_each_country DESC


-- Maximum number of deaths of each country

SELECT location, 
	   MAX(CAST(total_deaths AS INT)) AS Total_Deaths
From Covid..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY Total_Deaths DESC


-- Maximum number of deaths of each continent

SELECT continent, 
	   MAX(CAST(total_deaths AS INT)) AS Total_Deaths
From Covid..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY Total_Deaths DESC


-- I discovered that these numbers before is not accurate
-- This is the accurate numbers

SELECT location, 
	   MAX(CAST(total_deaths AS INT)) AS Total_Deaths
From Covid..CovidDeaths$
WHERE continent IS NULL
GROUP BY location 
ORDER BY Total_Deaths DESC


-- Calculating the percentage of deaths per day

SELECT 
    format(date,'dd-MM-yyyy') AS Date, 
    SUM(new_cases) AS Total_Cases, 
    SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 
    END AS Death_Percentage
FROM Covid..CovidDeaths$
WHERE continent IS NULL
GROUP BY date
ORDER BY date



-- Calculating the percentage of deaths of all time

SELECT 
    SUM(new_cases) AS Total_Cases, 
    SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 
    END AS Death_Percentage
FROM Covid..CovidDeaths$
WHERE continent IS NULL



-- Showing the new vaccinations per day for each country

SELECT cd.continent, 
	   cd.location, 
	   format(cd.date,'dd-MM-yyyy') AS Date, 
	   cd.population, 
	   cv.new_vaccinations
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY cd.location , Date


-- Showing the Total vaccinations for each country by using patition by

SELECT cd.continent, 
	   cd.location, 
	   format(cd.date,'dd-MM-yyyy') AS Date, 
	   cd.population, 
	   cv.new_vaccinations, 
	   SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location) AS Total_vaccinations_per_country
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY cd.location , Date


-- Showing the Total vaccinations for each country by using patition by and ordered by location and date

SELECT cd.continent, 
	   cd.location, 
       format(cd.date,'dd-MM-yyyy') AS Date, 
	   cd.population , cv.new_vaccinations, 
	   SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date)
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL


-- Use CTE (to make more calculations)

WITH population_VS_vaccination (Continent , location , Date , Population , New_vaccinations , Total_vaccinations_per_country)
AS
(
SELECT cd.continent, 
cd.location, 
format(cd.date,'dd-MM-yyyy') AS Date, 
cd.population, 
cv.new_vaccinations, 
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) AS Total_vaccinations_per_country
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)

Select *, 
	   ROUND((Total_vaccinations_per_country / population),4) * 100 AS Total_vaccinations_per_country_percentage 

FROM population_VS_vaccination


-- Temp Table (#percentage_of_population_vaccinated) for each country 

CREATE TABLE #percentage_of_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Total_vaccinations_per_country numeric
)

INSERT INTO #percentage_of_population_vaccinated
SELECT cd.continent, 
cd.location, 
cd.date, 
cd.population, 
cv.new_vaccinations, 
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) AS Total_vaccinations_per_country
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL


Select *, 
	   ROUND((Total_vaccinations_per_country / population),4) * 100 AS Total_vaccinations_per_country_percentage 

FROM #percentage_of_population_vaccinated


-- Another Temp Table (#percentage_of_population_vaccinated) for each continent 

DROP TABLE IF EXISTS #percentage_of_population_vaccinated
CREATE TABLE #percentage_of_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Total_vaccinations_per_country numeric
)

INSERT INTO #percentage_of_population_vaccinated
SELECT cd.continent, 
cd.location, 
cd.date, 
cd.population, 
cv.new_vaccinations, 
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) AS Total_vaccinations_per_continent
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NULL


Select *, 
	   ROUND((Total_vaccinations_per_country / population),4) * 100 AS Total_vaccinations_per_continent_percentage 

FROM #percentage_of_population_vaccinated



-- Creating a View

CREATE VIEW Total_deaths_of_each_country
AS
SELECT location, 
	   MAX(CAST(total_deaths AS INT)) AS Total_Deaths
From Covid..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location 

-- using that view
SELECT * 
FROM Total_deaths_of_each_country
ORDER BY Total_Deaths DESC                -- I use order by here because i can't use it in view



-- Another View

CREATE VIEW percentage_of_population_vaccinated
AS
SELECT cd.continent, 
cd.location, 
cd.date, 
cd.population, 
cv.new_vaccinations, 
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) AS Total_vaccinations_per_continent
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL


-- using that view
SELECT * 
FROM percentage_of_population_vaccinated

















