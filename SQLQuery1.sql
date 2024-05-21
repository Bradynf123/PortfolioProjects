
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4



Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
Where location like '%states%'
order by 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
--Where location like '%states%'
order by 1,2


-- Looking at countries with highest infection rate compared to population 

Select location, population,MAX(total_cases) as HighestInfectionCount, 
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
--Where location like '%states%'
Group By Location, Population
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null
Group By Location
order by TotalDeathCount desc





-- Showing continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null
Group By continent
order by TotalDeathCount desc





-- GLOBAL NUMBERS

SELECT 
    date,  
    SUM(new_deaths) AS total_deaths, 
    SUM(CAST(new_cases AS INT)) AS total_cases,
    CASE 
        WHEN SUM(CAST(new_cases AS INT)) = 0 THEN 0 -- Handling division by zero
        ELSE (SUM(new_deaths) / SUM(CAST(new_cases AS INT))) * 100 
    END AS death_percentage
FROM 
    PortfolioProject..covidDeaths
GROUP BY 
    date
ORDER BY 
    date;

SELECT 
    MAX(date) AS date,
    SUM(CAST(new_cases AS BIGINT)) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    CASE 
        WHEN SUM(CAST(new_cases AS BIGINT)) = 0 THEN NULL
        ELSE (SUM(new_deaths) / NULLIF(SUM(CAST(new_cases AS BIGINT)), 0)) * 100 
    END AS death_percentage
FROM 
    PortfolioProject..covidDeaths;

--use cte
WITH popvsvac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    *,
    (rolling_people_vaccinated / population) * 100 AS percentage_vaccinated
FROM 
    popvsvac;


--creating view to store data for later visualizations

create view percent_population_vaccinated as WITH popvsvac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    *,
    (rolling_people_vaccinated / population) * 100 AS percentage_vaccinated
FROM 
    popvsvac;