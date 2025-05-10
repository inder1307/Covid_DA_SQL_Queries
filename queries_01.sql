-- Looking at Total Cases VS Total Deaths

SELECT 
location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Mortality_rate
FROM `eco-limiter-455715-j1.SQL_project_01.Covid_Deaths` 
WHERE location = 'India'
ORDER BY 5 DESC NULLS LAST


--Looking at what percnetage of people got the covid (Cumulative Incidence Rate)
SELECT 
location, date, total_cases, total_deaths, (total_cases/population)*100 AS CI_Rate
FROM `eco-limiter-455715-j1.SQL_project_01.Covid_Deaths` 
WHERE location = 'United States'
ORDER BY 5 DESC NULLS LAST

--Looking at how many people died. Adding a null filter to avoid locations labelled as continents
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `eco-limiter-455715-j1.SQL_project_01.Covid_Deaths` 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Looking at the same data points, but this time grouping them by Continents
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `eco-limiter-455715-j1.SQL_project_01.Covid_Deaths` 
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Examining Global Numbers
SELECT date, SUM(new_cases) AS Cases, SUM(new_deaths) AS Deaths, SAFE_DIVIDE(SUM(new_deaths), SUM(new_cases))*100 AS DeathPercentage
FROM `eco-limiter-455715-j1.SQL_project_01.Covid_Deaths`
GROUP BY date 
order by 1,2

-- Calculating Total death and cases
SELECT SUM(new_cases) AS Cases, SUM(new_deaths) AS Deaths, SAFE_DIVIDE(SUM(new_deaths), SUM(new_cases))*100 AS DeathPercentage
FROM `eco-limiter-455715-j1.SQL_project_01.Covid_Deaths`
WHERE continent is NOT NULL
order by 1,2

-- Now we will start with analysing Covid Vcacinations Table
SELECT *
FROM eco-limiter-455715-j1.SQL_project_01.Covid_Vaccinations

-- Joining the two tables on date and location and performing cumulative sum on new vaccination column
SELECT Dea.continent, Dea.location, Dea.date, Dea.population , Vac.new_vaccinations,
        SUM(Vac.new_vaccinations) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingCount
FROM eco-limiter-455715-j1.SQL_project_01.Covid_Vaccinations Vac
JOIN eco-limiter-455715-j1.SQL_project_01.Covid_Deaths Dea
  ON Vac.date = Dea.date
  AND Vac.location = Dea.location
WHERE dea.continent is NOT NULL AND Dea.location = 'Canada'
ORDER BY 1,2,3

-- Using Sub-Queries to further calculate new data points using the Rolling Count
SELECT *, (RollingCount/population) *100 AS Test
FROM (SELECT Dea.continent, Dea.location, Dea.date, Dea.population , Vac.new_vaccinations,
        SUM(Vac.new_vaccinations) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingCount
FROM eco-limiter-455715-j1.SQL_project_01.Covid_Vaccinations Vac
JOIN eco-limiter-455715-j1.SQL_project_01.Covid_Deaths Dea
  ON Vac.date = Dea.date
  AND Vac.location = Dea.location
WHERE dea.continent is NOT NULL AND Dea.location = 'Canada'
ORDER BY 1,2,3
) 

-- Using CTE to perform the same query
WITH RollingVaccinations AS (
  SELECT 
    Dea.continent, 
    Dea.location, 
    Dea.date, 
    Dea.population, 
    Vac.new_vaccinations,
    SUM(Vac.new_vaccinations) OVER (
      PARTITION BY Dea.location 
      ORDER BY Dea.location, Dea.date
    ) AS RollingCount
  FROM `eco-limiter-455715-j1.SQL_project_01.Covid_Vaccinations` Vac
  JOIN `eco-limiter-455715-j1.SQL_project_01.Covid_Deaths` Dea
    ON Vac.date = Dea.date AND Vac.location = Dea.location
  WHERE Dea.continent IS NOT NULL AND Dea.location = 'Canada'
)

SELECT *, 
       (RollingCount / population) * 100 AS Test
FROM RollingVaccinations
ORDER BY location, date;

-- Using Temp Table to perform the same query
CREATE TEMP TABLE TempVaccinationStats AS
SELECT 
  Dea.continent, 
  Dea.location, 
  Dea.date, 
  Dea.population, 
  Vac.new_vaccinations,
  SUM(Vac.new_vaccinations) OVER (
    PARTITION BY Dea.location 
    ORDER BY Dea.location, Dea.date
  ) AS RollingCount
FROM `eco-limiter-455715-j1.SQL_project_01.Covid_Vaccinations` Vac
JOIN `eco-limiter-455715-j1.SQL_project_01.Covid_Deaths` Dea
  ON Vac.date = Dea.date AND Vac.location = Dea.location
WHERE Dea.continent IS NOT NULL AND Dea.location = 'Canada';

SELECT *, 
       (RollingCount / population) * 100 AS Test
FROM TempVaccinationStats
ORDER BY location, date;



--Creating a view for further analysis/visualization
CREATE OR REPLACE VIEW `eco-limiter-455715-j1.SQL_project_01.Canada_Vaccination_View` AS
WITH RollingVaccinations AS (
  SELECT 
    Dea.continent, 
    Dea.location, 
    Dea.date, 
    Dea.population, 
    Vac.new_vaccinations,
    SUM(Vac.new_vaccinations) OVER (
      PARTITION BY Dea.location 
      ORDER BY Dea.date
    ) AS RollingCount
  FROM `eco-limiter-455715-j1.SQL_project_01.Covid_Vaccinations` Vac
  JOIN `eco-limiter-455715-j1.SQL_project_01.Covid_Deaths` Dea
    ON Vac.date = Dea.date AND Vac.location = Dea.location
  WHERE Dea.continent IS NOT NULL AND Dea.location = 'Canada'
)

SELECT *, 
       (RollingCount / population) * 100 AS VaccinatedPercentage
FROM RollingVaccinations;



