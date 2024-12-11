Select * 
From PortofolioProj..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From PortofolioProj..CovidVaccinations
--order by 3,4

--Select data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProj..CovidDeaths
order by 1,2


-- Looking at total cases vs total deaths (deaths_per_case)
-- Reveals chance of a death from contraction of the disease
Select location, date,total_cases, total_deaths, ( cast(total_deaths as float)/cast(total_cases as float))*100 as 'deaths_per_case(%)'
From PortofolioProj..CovidDeaths
where location like '%Ghana%' and continent is not null
order by 1,2


-- Looking at total cases vs total population
-- shows probability of contracting the disease, i.e percentage of population that has Covid
Select location, date, population, total_cases, ( cast(total_cases as float)/cast(population as float))*100 as 'case_per_population(%)'
From PortofolioProj..CovidDeaths
where location like '%Ghana%' and continent is not null
order by 1,2

-- Looking at countries with most infection rates vs population
Select location, population, MAX(cast(total_cases as int)) as totalCases, ( MAX(cast(total_cases as float))/cast(population as float))*100 as 'cases_per_population(%)'
From PortofolioProj..CovidDeaths
where continent is not null
Group by location, population
order by 'cases_per_population(%)' desc


-- Looking at countries with the highest deaths due to covid per population
Select location, population, MAX(cast(total_deaths as int)) as totalDeaths, ( MAX(cast(total_deaths as float))/cast(population as float))*100 as 'deaths_per_population(%)'
From PortofolioProj..CovidDeaths
where continent is not null
Group by location, population
order by 'deaths_per_population(%)' desc


-- Looking at countries with highest death counts
Select location, MAX(cast(total_deaths as int)) as totalDeaths
From PortofolioProj..CovidDeaths
where continent is not null
Group by location
order by totalDeaths desc


-- Continental stats, from csv/excel sheet, we notice that the location without value in continent column is the correct continent stats
-- total deaths
Select continent, MAX(cast(total_deaths as int)) as totalDeaths
From PortofolioProj..CovidDeaths
where continent is not null
Group by continent
order by totalDeaths desc


-- GLOBAL NUMBERS
Select SUM(cast(new_cases as int)) as totalCases, 
	   SUM(cast(new_deaths as int)) as totalDeaths,
	   (SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 'DeathVCase(%)'
From PortofolioProj..CovidDeaths
where continent is not null
--Group by date

--  Global per day
Select date, 
       SUM(cast(new_cases as int)) as totalCases, 
	   SUM(cast(new_deaths as int)) as totalDeaths,
	   (SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 'DeathVCase(%)'
From PortofolioProj..CovidDeaths
where continent is not null
Group by date
order by 1


-- Looking at total population vs vaccinations
Select deaths.continent, 
	   deaths.location, 
	   deaths.date, 
	   deaths.population, 
	   SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as VaccinationCountRollOver
From PortofolioProj..CovidDeaths deaths
Join PortofolioProj..CovidVaccinations vac
	On deaths.location = vac.location
	and deaths.date = vac.date
Where deaths.continent is not null
	  and vac.continent is not null
order by 2,3


-- USE CTE
-- Was unable to use the alias column name in this query, was appropriate to use CTE instead for the whole query
With PopVsVac (Continent, Location, Date, Population,NewVaccinations, VaccinationCountRollOver)
as(
Select deaths.continent, 
	   deaths.location, 
	   deaths.date, 
	   deaths.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) --Used Partition instead of Group by to avoid removing columns and manipulate aggregate more precisely
From PortofolioProj..CovidDeaths deaths
Join PortofolioProj..CovidVaccinations vac
	On deaths.location = vac.location
	and deaths.date = vac.date
Where deaths.continent is not null
	  and vac.continent is not null
-- order by 2,3
)
Select *,(VaccinationCountRollOver/Population)*100
From PopVsVac



-- TEMP TABLE
DROP TABLE IF EXISTS #VaccinatedPercentage
Create Table #VaccinatedPercentage
(
Continent nvarchar(50),
Location nvarchar(255),
Date datetime,
Population nvarchar(255),
New_vaccinations nvarchar(255),
VaccinationCountRollOver numeric
)


Insert into #VaccinatedPercentage
Select deaths.continent, 
	   deaths.location, 
	   deaths.date, 
	   deaths.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as VaccinationCountRollOver
From PortofolioProj..CovidDeaths deaths
Join PortofolioProj..CovidVaccinations vac
	On deaths.location = vac.location
	and deaths.date = vac.date
Where deaths.continent is not null
	  and vac.continent is not null
order by 2,3


Select *,(VaccinationCountRollOver/Population)*100
From #VaccinatedPercentage	
order by 2,3




--Views to store data for visualizations
Create View PercentagePopulationVaccinated as
Select deaths.continent, 
	   deaths.location, 
	   deaths.date, 
	   deaths.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as VaccinationCountRollOver
From PortofolioProj..CovidDeaths deaths
Join PortofolioProj..CovidVaccinations vac
	On deaths.location = vac.location
	and deaths.date = vac.date
Where deaths.continent is not null
	  and vac.continent is not null
