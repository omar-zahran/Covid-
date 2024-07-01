-- Showing the data from (CovidDeaths) table

Select * 
FROM Covid..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY location;


-- Showing the data from (CovidVaccinations) table
Select * 
FROM Covid..CovidVaccinations$
WHERE continent IS NOT NULL
ORDER BY location;


-- Total cases VS Total deaths & The percentage between them
-- Here is the The percentage of Total deaths to Total cases in Egypt Per day

SELECT location, 
	   CONVERT(date,date) AS Date,
	   total_cases, 
	   total_deaths, 
	   ROUND((total_deaths/total_cases)*100,2) AS The_percentage_of_death
From Covid..CovidDeaths$
WHERE location = 'Egypt'
AND continent IS NOT NULL;


-- Total cases VS Total deaths & The percentage between them
-- Here is the The percentage of Total deaths to Total cases in Asia Per day

SELECT location, 
	   CONVERT(date,date) AS Date,
	   total_cases, 
	   total_deaths, 
	   ROUND((total_deaths/total_cases)*100,2) AS The_percentage_of_death
From Covid..CovidDeaths$
WHERE location = 'Africa'
AND continent IS NULL;


-- Total Cases VS Population & The percentage between them
-- Here is the The percentage of infected people in united states

SELECT location, 
	   CONVERT(date,date) AS Date, 
	   total_cases, 
	   population, 
	   ROUND((total_cases/population)*100,2) AS The_percentage_of_infected_people
From Covid..CovidDeaths$
WHERE location = 'united states'
AND continent IS NOT NULL
ORDER BY Date;



-- Total Cases VS Population & The percentage between them
-- Here is the The percentage of infected people in Europe

SELECT location, 
	   CONVERT(date,date) AS Date, 
	   total_cases, 
	   population, 
	   ROUND((total_cases/population)*100,2) AS The_percentage_of_infected_people
From Covid..CovidDeaths$
WHERE location = 'Europe'
AND continent IS NULL
ORDER BY Date;


-- Total Deaths VS Population & The percentage between them
-- Here is the The percentage of Deaths people in united states

SELECT location, 
	   CONVERT(date,date) AS Date, 
	   total_deaths, 
	   population, 
	   ROUND((total_deaths/population)*100,4) AS The_percentage_of_deaths_people
From Covid..CovidDeaths$
WHERE location = 'united states'
AND continent IS NOT NULL
ORDER BY Date; 


-- Total Deaths VS Population & The percentage between them
-- Here is the The percentage of Deaths people in Europe

SELECT location, 
	   CONVERT(date,date) AS Date, 
	   total_deaths, 
	   population, 
	   ROUND((total_deaths/population)*100,4) AS The_percentage_of_deaths_people
From Covid..CovidDeaths$
WHERE location = 'Europe'
AND continent IS NULL
ORDER BY Date; 


-- Top 10 Countries by Total Cases

SELECT TOP 10 cd.location, 
       SUM(CONVERT(NUMERIC, total_cases)) AS Total_Cases
FROM Covid..CovidDeaths$ cd 
WHERE cd.continent IS NOT NULL
GROUP BY cd.location
ORDER BY Total_Cases DESC;


-- Top 10 Countries by Total Deaths

SELECT TOP 10 cd.location, 
       SUM(CONVERT(NUMERIC, total_deaths)) AS Total_Deaths
FROM Covid..CovidDeaths$ cd 
WHERE cd.continent IS NOT NULL
GROUP BY cd.location
ORDER BY Total_Deaths DESC;


-- Maximum number of cases of each country

SELECT location, 
	   MAX(CAST(total_cases AS INT)) AS Total_Cases
From Covid..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY Total_Cases DESC;


-- Maximum number of deaths of each country

SELECT location, 
	   MAX(CAST(total_deaths AS INT)) AS Total_Deaths
From Covid..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY Total_Deaths DESC;


-- Combined Total Cases and Deaths by Country

SELECT location, SUM(CAST(total_cases AS NUMERIC)) AS Total_Count,  'Cases' AS Type
FROM Covid..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
UNION
SELECT location, SUM(CAST(total_deaths AS NUMERIC)) AS Total_Count, 'Deaths' AS Type
FROM Covid..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location, Type;


-- Maximum infected Percentage of each Country

SELECT location, 
	   population, 
	   MAX(total_cases) AS maximum_infected_Cases, 
	   ROUND(MAX((total_cases/population))*100,3) AS maximum_infected_percentage_of_each_country
From Covid..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location , population
ORDER BY maximum_infected_percentage_of_each_country DESC;


-- Maximum number of deaths of each continent

SELECT location, 
	   MAX(CAST(total_deaths AS NUMERIC)) AS Total_Deaths
From Covid..CovidDeaths$
WHERE continent IS NULL
GROUP BY location 
ORDER BY Total_Deaths DESC;


-- Calculating the percentage of deaths per day

SELECT 
    CONVERT(date,date) AS Date, 
    SUM(new_cases) AS Total_Cases, 
    SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE ROUND(SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100,2)
    END AS Death_Percentage
FROM Covid..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Date
ORDER BY Date;


-- Calculating the percentage of deaths of all time

SELECT 
    SUM(new_cases) AS Total_Cases, 
    SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE ROUND(SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100,2)
    END AS Death_Percentage
FROM Covid..CovidDeaths$
WHERE continent IS NOT NULL;


-- Daily Average New Cases and Deaths for a Specific Continent (Asia)

SELECT location, 
       CONVERT(date, date) AS Date,
       ROUND(AVG(CAST(new_cases AS INT)),5) AS Average_Daily_New_Cases, 
       ROUND(AVG(CAST(new_deaths AS INT)),5) AS Average_Daily_New_Deaths
FROM Covid..CovidDeaths$ 
WHERE location = 'Asia'
AND continent IS NULL
GROUP BY location, Date
ORDER BY Date;


-- Cumulative Cases and Deaths for the Top 5 Most Populated Countries

WITH Top_Populated_Countries AS (
    SELECT TOP 5 location
    FROM Covid..CovidDeaths$
    WHERE continent IS NOT NULL
    GROUP BY location
    ORDER BY MAX(population) DESC
    
)
SELECT location, 
       date,
       SUM(CAST(new_cases AS NUMERIC)) OVER (PARTITION BY location ORDER BY date) AS Cumulative_Cases, 
       SUM(CAST(new_deaths AS NUMERIC)) OVER (PARTITION BY location ORDER BY date) AS Cumulative_Deaths
FROM Covid..CovidDeaths$ 
WHERE location IN (SELECT location FROM Top_Populated_Countries)
ORDER BY location, date;


-- Increasing in Daily New Cases for specific country

SELECT a.location, 
	   CONVERT(date,a.date) AS Date, 
	   a.new_cases AS Current_Day_Cases, 
	   b.new_cases AS Previous_Day_Cases,
	   a.new_cases - b.new_cases AS increase_OR_decrease  
FROM Covid..CovidDeaths$ a
JOIN Covid..CovidDeaths$ b
ON a.location = b.location
AND a.date = DATEADD(day, 1, b.date)
WHERE a.continent IS NOT NULL
AND a.location = 'Egypt'
ORDER BY a.location, a.date;

-- OR --

SELECT location, 
       CONVERT(date, date) AS Date, 
       new_cases AS Current_Day_Cases, 
       LAG(new_cases) OVER (ORDER BY date) AS Previous_Day_Cases,
       new_cases - LAG(new_cases) OVER (ORDER BY date) AS increase_OR_decrease  
FROM Covid..CovidDeaths$
WHERE continent IS NOT NULL
AND location = 'Egypt'
ORDER BY location, date;


-- Showing the new vaccinations per day for each country

SELECT cd.location, 
	   format(cd.date,'dd-MM-yyyy') AS Date, 
	   cv.new_vaccinations
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY cd.location , Date;


-- Showing the new vaccinations and Cumulative Total vaccinations for each country 

SELECT cd.location, 
       FORMAT(cd.date,'dd-MM-yyyy') AS Date, 
	   cv.new_vaccinations, 
	   SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) AS Total_vaccinations
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;


-- Creating View Showing the Total vaccinations for each country

CREATE VIEW Total_Vaccinations_of_each_country
AS
SELECT cd.location, 
       SUM(CAST(cv.new_vaccinations AS NUMERIC)) AS Total_Vaccinations
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
WHERE cd.continent IS NOT NULL
GROUP BY cd.location;

-- using that view --
SELECT * 
FROM Total_Vaccinations_of_each_country
ORDER BY Total_Vaccinations DESC; 



-- Showing the Total vaccinations for each Continent

SELECT cd.location, 
       SUM(CAST(cv.new_vaccinations AS NUMERIC)) AS Total_Vaccinations
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
WHERE cd.continent IS NULL
GROUP BY cd.location
ORDER BY Total_Vaccinations DESC;


-- Top 10 Countries by Total Vaccinations

SELECT TOP 10 cd.location, 
       SUM(CONVERT(NUMERIC, cv.new_vaccinations)) AS Total_Vaccinations
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
WHERE cd.continent IS NOT NULL
GROUP BY cd.location
ORDER BY Total_Vaccinations DESC;


-- Top 2 Continents by Total Vaccinations

SELECT TOP 3 cd.location, 
       SUM(CONVERT(NUMERIC, cv.new_vaccinations)) AS Total_Vaccinations
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
WHERE cd.continent IS NULL
GROUP BY cd.location
ORDER BY Total_Vaccinations DESC;


-- Total Cases, Deaths, and Vaccinations by Month for a Specific Country

SELECT cd.location, 
       YEAR(cd.date) AS Year, 
       MONTH(cd.date) AS Month, 
       SUM(cd.total_cases) AS Total_Cases, 
       SUM(CAST(cd.total_deaths AS NUMERIC)) AS Total_Deaths, 
       SUM(CAST(cv.new_vaccinations AS NUMERIC)) AS Total_Vaccinations
FROM Covid..CovidDeaths$ cd 
JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.location = 'Russia'
AND cd.continent IS NOT NULL
GROUP BY cd.location, YEAR(cd.date), MONTH(cd.date)
ORDER BY Year, Month;


-- Countries with Highest Vaccination Rates Relative to Population

SELECT TOP 10 cd.location, 
		      cd.population, 
			  SUM(CAST(cv.new_vaccinations AS NUMERIC)) AS Total_Vaccinations, 
			  ROUND((SUM(CAST(cv.new_vaccinations AS NUMERIC)) / cd.population),4) * 100 AS Vaccination_Rate
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, cd.population
ORDER BY Vaccination_Rate DESC;


-- Total Vaccinations vs. Total Deaths by Continent

SELECT cd.location, 
       SUM(CAST(cv.new_vaccinations AS NUMERIC)) AS Total_Vaccinations, 
       SUM(CAST(cd.total_deaths AS NUMERIC)) AS Total_Deaths
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NULL
GROUP BY cd.location
ORDER BY cd.location;


-- Vaccination Rates and Case Fatality Rate by Country

SELECT cd.location, 
       cd.population, 
       SUM(CAST(cv.new_vaccinations AS NUMERIC)) AS Total_Vaccinations, 
       (SUM(CAST(cv.new_vaccinations AS NUMERIC)) / cd.population) * 100 AS Vaccination_Rate, 
       SUM(CAST(cd.total_deaths AS NUMERIC)) AS Total_Deaths, 
       SUM(CAST(cd.total_cases AS NUMERIC)) AS Total_Cases, 
       (SUM(CAST(cd.total_deaths AS NUMERIC)) / SUM(CAST(cd.total_cases AS NUMERIC))) * 100 AS Case_Fatality_Rate
FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, cd.population
ORDER BY Vaccination_Rate DESC;


-- Creating Temp Table (#percentage_of_population_vaccinated) for each continent 

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
WHERE cd.continent IS NULL;

-- Use the Temp Table

Select *, ROUND((Total_vaccinations_per_country / population),4) * 100 AS Total_vaccinations_per_continent_percentage 
FROM #percentage_of_population_vaccinated;



-- Create an Index on Location and Date

CREATE INDEX idx_location_date ON Covid..CovidDeaths$ (location, date);



-- Create function calculates the total number of vaccinations for a specified location. (Scalar Fun.)


CREATE FUNCTION get_tot_Vac (@location NVARCHAR(255))
RETURNS NUMERIC
AS
BEGIN
    DECLARE @TotalVaccinations NUMERIC;

    SELECT @TotalVaccinations = SUM(CONVERT(NUMERIC, cv.new_vaccinations))
    FROM Covid..CovidDeaths$ cd
    INNER JOIN Covid..CovidVaccinations$ cv ON cd.location = cv.location
    WHERE cd.continent IS NOT NULL
      AND cd.location = @location;

    RETURN @TotalVaccinations;
END;

GO

SELECT dbo.get_tot_Vac('United States') AS Total_Vaccinations;



-- Create inline table-valued function that returns a table with specific columns related to COVID-19 data for a specified location. (inline Fun.)

CREATE FUNCTION Infected_Percentage(@location NVARCHAR(255))
RETURNS TABLE
AS
RETURN
(
    SELECT location, 
           CONVERT(date, date) AS Date, 
           total_cases, 
           population, 
           ROUND((total_cases/population)*100, 2) AS The_percentage_of_infected_people
    FROM Covid..CovidDeaths$
    WHERE location = @location
    AND continent IS NULL
);

GO

SELECT * 
FROM Infected_Percentage('Europe');



-- Create a multi-statement table-valued function that retrieves COVID-19 vaccination data by location and date. (Multi-Statement Fun.)

CREATE FUNCTION Vaccinations()
RETURNS @Result TABLE 
(
    location NVARCHAR(255),
    Date NVARCHAR(10),
    new_vaccinations INT
)
AS
BEGIN
    INSERT INTO @Result
    SELECT cd.location, 
           FORMAT(cd.date, 'dd-MM-yyyy') AS Date, 
           cv.new_vaccinations
    FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
    ON cd.location = cv.location
    AND cd.date = cv.date
    WHERE cd.continent IS NOT NULL
    ORDER BY cd.location, Date;

    RETURN;
END;

GO

SELECT * 
FROM Vaccinations();


-- Create a Stored Procedure to Get COVID-19 Statistics for a Specific Country

CREATE PROCEDURE Get_Covid_Stats 
    @Country NVARCHAR(255)
AS
BEGIN
    SELECT cd.location, 
           FORMAT(cd.date,'dd-MM-yyyy') AS Date,  
           cd.total_cases, 
           cd.total_deaths, 
		   cv.total_vaccinations
    FROM Covid..CovidDeaths$ cd INNER JOIN Covid..CovidVaccinations$ cv
	ON cd.location = cv.location
	AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
    AND cd.location = @Country
    ORDER BY Date;
END;

GO

--Execute the Stored Procedure
EXEC Get_Covid_Stats @Country = 'Egypt';








