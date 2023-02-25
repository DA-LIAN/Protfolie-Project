Select *
From PortfolioProject..CovidDeaths
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

 --Select data that we are using

 Select location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths
 order by 1,2

 --Looking at Total cases Cases vs Total Deaths
 --Shows likehood of dying if you contract covid in your country
 Select location, date, total_cases, total_deaths,(total_deaths/total_cases) AS DeatgPercent
 From PortfolioProject..CovidDeaths
 Where location like '%state%'
 order by 1,2

 --Looking at Total Cases vs Population
 --Shows what percentage of population got Covid
 Select location, date, population, total_cases, (total_deaths/population) AS PercentPopulationDeath
 From PortfolioProject..CovidDeaths
 Where location like '%state%'
 order by 1,2

 --Looking at countries with Highest Infection Rate compared to Population

 Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 AS 
		PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 --Where location like '%states%'
 Group by location,population
 order by PercentPopulationInfected desc


 --Showing countries With Highest Death count per Populaton

 Select Location, MAX(cast(Total_deaths AS int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 --Where location like '%states%'
 where continent is not null
 Group by location
 order by TotalDeathCount desc


 --Let's break things down by continent

 --Showing contintents with the highest death count per population
  Select Location, MAX(cast(Total_deaths AS int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 --Where location like '%states%'
 where continent is not null
 Group by location
 order by TotalDeathCount desc


 --Global numbers

 Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  
		sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 --Where location like '%states%'
 where continent is not null
 --Group by date
 order by 1,2


 --Looking at Total Population vs Vaccination
 --CTE

 with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccined)	
 as
 (
 Select dea.continent, 
	 dea.location, 
	 dea.date, 
	 dea.population, 
	 vac.new_vaccinations,
	 sum(convert(int,vac.new_vaccinations)) over 
	 (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccined
 -- (RollingPeopleVaccined/population)*100
From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)

select*,(RollingPeopleVaccined/Population)*100
From PopvsVac


--Temp table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225) , 
location nvarchar(225),
date datetime, 
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccined numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, 
	 dea.location, 
	 dea.date, 
	 dea.population, 
	 vac.new_vaccinations,
	 sum(convert(int,vac.new_vaccinations)) over 
	 (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccined
 -- (RollingPeopleVaccined/population)*100
From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select*,(RollingPeopleVaccined/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visulaiztion

--Drop view if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as 
Select dea.continent, 
	 dea.location, 
	 dea.date, 
	 dea.population, 
	 vac.new_vaccinations,
	 sum(convert(int,vac.new_vaccinations)) over 
	 (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccined
 -- (RollingPeopleVaccined/population)*100
From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 


Select*
From PercentPopulationVaccinated