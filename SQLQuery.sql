
-- Covid Death data
SELECT *
FROM [PortfolioProject].[dbo].[CovidDeaths$]
ORDER BY 3,4 

--Covid vaccine data
SELECT *
FROM [PortfolioProject].[dbo].[CovidVaccinations$]
ORDER BY 3,4 

--Top 20 ountries with most cases
SELECT TOP 20 location, MAX(total_cases) AS Total_cases,population
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL 
GROUP  BY location, population
ORDER BY Total_cases DESC

-- Total deaths by country
SELECT location,date, total_cases,new_cases,total_deaths,population
FROM [PortfolioProject].[dbo].[CovidDeaths$]
ORDER BY 1,2

-- Total cases vs total deaths (Percentage of people who died after getting infected)
SELECT location,date, total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
ORDER BY 1,2

--Total cases vs population 
SELECT location,date, total_cases,population,(total_cases/population)*100 AS PercentageInfected
FROM [PortfolioProject].[dbo].[CovidDeaths$] 
ORDER BY 1,2

--Countries with hgighest infection rate
SELECT location, MAX(total_cases) AS Total_cases,population,MAX(total_cases/population)*100 AS PercentageInfected
FROM [PortfolioProject].[dbo].[CovidDeaths$]
GROUP  BY location,population 
ORDER BY PercentageInfected DESC

--Countries with highest death count 
SELECT location, MAX(CAST(total_deaths AS int)) AS Total_deaths
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL 
GROUP  BY  location
ORDER BY Total_deaths DESC

--Total cases by continent
SELECT continent, MAX(total_cases) AS Total_cases
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Total_cases DESC

--Infection rate by continent
SELECT continent, MAX(total_cases) AS Total_cases,ROUND(MAX(total_cases/population)*100,2) AS PercentageInfected
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE continent is NOT NULL
GROUP  BY continent 
ORDER BY PercentageInfected DESC

--Deaths by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_deaths
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL
GROUP  BY  continent
ORDER BY Total_deaths DESC

--Global numbers
SELECT SUM(new_cases) AS Total_cases,SUM(CAST(new_deaths AS INT)) AS Total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases)) AS Death_Percetage --,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1


--Total population vs vaccinated using CTEs
With popvacntd as 
(
SELECT deaths.continent,deaths.location,deaths.date,deaths.population, vaccs.new_vaccinations, SUM(CAST(vaccs.new_vaccinations AS BIGINT)) OVER(PARTITION BY deaths.location ORDER BY deaths.date) AS Rolling_vaccinated_average
FROM [PortfolioProject].[dbo].[CovidDeaths$] AS deaths 
INNER JOIN [PortfolioProject].[dbo].[CovidVaccinations$] AS vaccs 
ON deaths.location=vaccs.location
AND deaths.date=vaccs.date
WHERE deaths.continent IS NOT NULL 
--ORDER  BY 2,3
)
Select  location, MAX((Rolling_vaccinated_average/population)*100) AS percentagevaccinated from popvacntd
GROUP BY location
ORDER BY 2 DESC

--Percentage of fully vaccinated people by 2023
SELECT deaths.location, MAX(deaths.total_cases) AS total_cases, MAX(CAST(People_fully_vaccinated AS bigint)) AS Vaccinated_people, deaths.population, (MAX(CAST(People_fully_vaccinated AS bigint))/deaths.population)*100 AS Percentage_fully_vaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths$] AS deaths INNER JOIN  [PortfolioProject].[dbo].[CovidVaccinations$] AS vaccs
ON deaths.location=vaccs.location AND deaths.date=vaccs.date
WHERE total_cases IS NOT NULL AND deaths.continent IS NOT NULL
GROUP BY deaths.location,deaths.population
ORDER BY Percentage_fully_vaccinated DESC

