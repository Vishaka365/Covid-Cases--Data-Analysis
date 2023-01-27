SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to use.

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'

--Total cases vs Population
--Percentage of population having covid
SELECT Location,date,population,total_cases,(total_cases/population)*100 as populationPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2

--Countries with highest infection rate compared to population
SELECT Location,population,MAX(total_cases) as HighestInfection,MAX(total_cases/population)*100 as populationPercentageInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
group by Location,population
order by populationPercentageInfected desc

SELECT Location,population,date,MAX(total_cases) as HighestInfection,MAX(total_cases/population)*100 as populationPercentageInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
group by Location,population,date
order by populationPercentageInfected desc

--Countries with highest death count per population
SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
group by Location
order by TotalDeathCounts desc

--Breaking data by CONTINENT
--Continent with highest death count per population

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by continent
order by TotalDeathCounts desc

--Global Numbers
SELECT date,SUM(new_cases) as new_cases,SUM(cast(new_deaths as int)) as new_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathPercent
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
order by 1,2

--Total Global numbers
SELECT SUM(new_cases) as new_cases,SUM(cast(new_deaths as int)) as new_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathPercent
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
order by 1,2

--European Union part of Europe
SELECT location,SUM(cast(new_deaths as int)) as Total_deathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
and location not in ('World','European Union','International')
GROUP BY location
order by Total_deathCount

--Joining 2 tables
--Total population vs Vaccinations

SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location
ORDER BY cd.location,cd.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
  on cd.location=cv.location
  and cd.date=cv.date
WHERE cd.continent is not null
order by 2,3

-- USE CTE
With PopvsVac(Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location
ORDER BY cd.location,cd.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
  on cd.location=cv.location
  and cd.date=cv.date
WHERE cd.continent is not null
--order by 2,3
)
SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP Table
DROP Table if exists #PercentPopulationVAccinated
CREATE Table #PercentPopulationVAccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVAccinated
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location
ORDER BY cd.location,cd.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
  on cd.location=cv.location
  and cd.date=cv.date
--WHERE cd.continent is not null
--order by 2,3

SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVAccinated


--Creating view to store data for later visualization
Create View PercentPopulationVAccinated as
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location
ORDER BY cd.location,cd.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
  on cd.location=cv.location
  and cd.date=cv.date
WHERE cd.continent is not null
--order by 2,3

Select *
From 
PercentPopulationVAccinated