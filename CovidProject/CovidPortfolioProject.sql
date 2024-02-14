
--Indicates the probability of mortality in the event of contracting COVID-19 in Tunisia.
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    TRY_CAST(total_deaths AS FLOAT) / TRY_CAST(total_cases AS FLOAT)* 100 AS death_rate_percentage
FROM PortfolioProject.dbo.CovidDeaths
	where location like '%Tunisia%'
	
ORDER BY 1, 2;

--Shows what percentage of the population got COVID-19 In Tunisia
	SELECT location , date , total_cases , population ,
	 (total_cases ) /  (population  ) *100 as InfectionPercentage
	from PortfolioProject.dbo.CovidDeaths
	where location like '%Tunisia%'
    ORDER BY 1, 2;

--Looking at countries with highest Infection rate compared to population
	SELECT location ,date, population, MAX(total_cases) as highestInfectionCount, 
    Max (total_cases ) /  (population  ) *100  as InfectionPercentage
	from PortfolioProject.dbo.CovidDeaths
	where date ='2023-12-13'
	Group by location , date, population 
	ORDER BY InfectionPercentage DESC ;

--Showing countries with Highest Death count 
  Select location,Max (cast(total_deaths as int)) as TotalDeathCount
  from PortfolioProject.dbo.CovidDeaths 
  	where  continent is not null
  Group by location
  Order by TotalDeathCount DESC


  --Showing Continents with Highest Death count 
  Select continent,Max (cast(total_deaths as int)) as TotalDeathCount
  from PortfolioProject.dbo.CovidDeaths 
  	where  continent is not null
  Group by continent
  Order by TotalDeathCount DESC

--Looking at how many people in the each country got vaccinated and the vaccinated percentage per population Using Cte
WITH PopoulationVsVac (continent ,location , date,population, new_vaccinations,RollingPeopleVaccinated)
as (
  Select Death.continent,Death.location,Death.date,Death.population, Vacc.new_vaccinations,
     SUM(cast(new_vaccinations as float)) OVER (partition by Death.location order by Death.location,Death.date) as RollingPeopleVaccinated
  from PortfolioProject.dbo.CovidDeaths as Death
  join PortfolioProject.dbo.CovidVaccinations as Vacc
      on Death.location = Vacc.location 
	  and Death.date=Vacc.date
      where Death.continent is not null
	  ) 
	  Select * , (RollingPeopleVaccinated/population)*100 as VaccinatedPerPopulation
	  from PopoulationVsVac



   --Looking at how many people in NorthAmerica got tested and the tests percentage per population Using TempTable

   DROP TABLE IF EXISTS #PercentPopulationTestedPositive
   Create Table #PercentPopulationTestedPositive
   (
   continent nvarchar(255),
   Location nvarchar(255),
   Date datetime,
   Population numeric,
   New_tests numeric,
   RollingPeopleTested numeric )

   INSERT INTO #PercentPopulationTestedPositive
     Select Death.continent,Death.location,Death.date,Death.population, Vacc.new_tests,
     SUM(cast(new_vaccinations as float)) OVER (partition by Death.location order by Death.location,Death.date) as RollingPeopleTested
  from PortfolioProject.dbo.CovidDeaths as Death
  join PortfolioProject.dbo.CovidVaccinations as Vacc
      on Death.location = Vacc.location 
	  and Death.date=Vacc.date
	  where Death.continent like '%North%'
	  	  Select * , (RollingPeopleTested/population)*100 as TestedPerPopulation
	  from #PercentPopulationTestedPositive


	  --Creating view to store date for visualisations
	  Create view PercentagePopulationVaccinated as 
	   Select Death.continent,Death.location,Death.date,Death.population, Vacc.new_vaccinations,
     SUM(cast(new_vaccinations as float)) OVER (partition by Death.location order by Death.location,Death.date) as RollingPeopleVaccinated
  from PortfolioProject.dbo.CovidDeaths as Death
  join PortfolioProject.dbo.CovidVaccinations as Vacc
      on Death.location = Vacc.location 
	  and Death.date=Vacc.date
      where Death.continent is not null