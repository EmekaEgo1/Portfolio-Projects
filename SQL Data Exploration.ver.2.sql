
Select *
From PortfolioProject..['CovidDeaths (CV)$']
Order by 1,2

--Select *
--From PortfolioProject..CovidVaccinate$
--Order by 1,2

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['CovidDeaths (CV)$']
Order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths (CV)$']
Where location like '%nigeria%'
Order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['CovidDeaths (CV)$']
Where location like '%nigeria%'
Order by 1,2

-- Lookng at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['CovidDeaths (CV)$']
--Where location like '%nigeria%'
Group by Location, population
Order by PercentPopulationInfected desc

-- Showing the countries with the highest death count per population

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths (CV)$']
--Where location like '%nigeria%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Showing the Continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths (CV)$']
--Where location like '%nigeria%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPecentage
From PortfolioProject..['CovidDeaths (CV)$']
--Where location like '%nigeria%'
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPecentage
From PortfolioProject..['CovidDeaths (CV)$']
--Where location like '%nigeria%'
Where continent is not null
Order by 1,2


-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..['CovidDeaths (CV)$'] dea
Join PortfolioProject..CovidVaccinate$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths (CV)$'] dea
Join PortfolioProject..CovidVaccinate$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- TEMP TABLE

Drop Table If exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths (CV)$'] dea
Join PortfolioProject..CovidVaccinate$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

-- Creating views to store for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['CovidDeaths (CV)$'] dea
Join PortfolioProject..CovidVaccinate$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From #PercentPopulationVaccinated