select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4


select continent, location, date, population, new_cases, total_cases, new_deaths, total_deaths
from PortfolioProject..CovidDeaths
where continent is not null
order by location, date



-- Total number of Covid cases till Date according to Countries

select max(total_cases) as TotalCasesTillDate, location from PortfolioProject..CovidDeaths
where continent is not null
group  by location
order by location


-- Country with the maximum number of cases till date

select top 1 max(total_cases) as TotalCasesTillDate, location from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalCasesTillDate desc


-- Total Number of Countries whose Covid Data is being Analysed

select count(distinct location) as TotalCountries from PortfolioProject..CovidDeaths
where continent is not null


-- Order of Deaths based upon Countries

select max(convert(int, total_deaths)) as TotalDeathsTillDate, location from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathsTillDate desc


-- Selecting data from Covid Vaccinations Table

select location, date, total_vaccinations from PortfolioProject..CovidVaccinations
where continent is not null
order by location, date


-- Number of People Vaccinated according to Countries

select max(convert(bigint, total_vaccinations)) as VaccinationsTillDate, location from PortfolioProject..CovidVaccinations
where continent is not null
group by location
order by VaccinationsTillDate desc


--  Deaths vs Vaccinations

select max(convert(int, cd.total_deaths)) as TotalDeathsTillDate, max(convert(bigint, cv.total_vaccinations)) as 
VaccinationsTillDate, cd.location
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
where cd.continent is not null
group by cd.location
order by TotalDeathsTillDate desc


-- Deaths vs Vaccinations vs Population in Whole World - Using CTE

with PopvsVac (TotalDeaths, TotalVaccinations, population, location) as
(
select max(convert(int, cd.total_deaths)) as TotalDeaths, max(convert(bigint, cv.total_vaccinations)) as TotalVaccinations, cd.population, cd.location
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
where cd.continent is not null
group by cd.location, cd.population
)

select sum(TotalDeaths) as TotalDeathsinWorld, sum(TotalVaccinations) as TotalVaccinationsinWorld, 
sum(distinct population) as TotalPopulationofWorld, (sum(TotalDeaths)/sum(distinct population))*100 as PercentPopulationwipedOffduetoCovid from PopvsVac

-- Vaccinations vs Population in Whole World(Important) - Using CTE

with PopvsVac (population, VaccinationsTillDate, location) as
(
select cd.population, max(convert(bigint, cv.total_vaccinations)) as 
VaccinationsTillDate, cd.location
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
where cd.continent is not null
group by cd.population, cd.location
)

select sum(VaccinationsTillDate) as TotalVaccinationsinWorld, sum(distinct population) TotalPopulationinWorld
from PopvsVac



-- Temp Table (Important)

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated





 -- gdp per capita according to Countries

 select gdp_per_capita, location from PortfolioProject..CovidVaccinations
 where continent is not null
 group by location, gdp_per_capita
 order by gdp_per_capita desc


 -- Total Vaccines utilised in whole world

 select max(convert(bigint, total_vaccinations)) as TotalVaccineUtilised, location
 from PortfolioProject..CovidVaccinations 
 where continent is not null 
 group by location
 order by location


 -- Countries with Highest Hospital beds per thousand vs Number of Deaths in that Country

 select cv.hospital_beds_per_thousand, max(convert(int, cd.total_deaths)) as TotalDeathsTillDate, cd.location
 from PortfolioProject..CovidVaccinations cv
 join PortfolioProject..CovidDeaths cd
 on cv.location = cd.location
 where cd.continent is not null
 group by cd.location, cv.hospital_beds_per_thousand
 order by hospital_beds_per_thousand desc


 -- Covid Tests vs Covid Cases

 select max(convert(int, cv.total_tests)) as TotalTestsTilldate, max(cd.total_cases) as TotalCasesTilldate,
 (max(convert(int, cv.total_tests))/max(cd.total_cases)) as Ratio, cd.location
 from PortfolioProject..CovidVaccinations cv
 join PortfolioProject..CovidDeaths cd
 on cv.location = cd.location
 where cd.continent is not null
 group by cd.location
 order by Ratio desc


 -- How the Covid Cases and Deaths propagated in a Country 

 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where continent is not null and location like '%states%'
 order by 1,2


 -- Cases vs Deaths till date according to Countries

 select location, max(convert(int, total_deaths)) as TotalDeaths, max(total_cases) as TotalCases, (max(convert(int, total_deaths))/max(total_cases))*100 
 as DeathPercentage from PortfolioProject..CovidDeaths 
 where continent is not null 
 group by location
 order by DeathPercentage desc


 -- How the Covid Cases have spread within a Country's Population
 
 select location, date, total_cases, population, (total_cases/population)*100 as CovidSpread
 from PortfolioProject..CovidDeaths
 where continent is not null and location like '%states%'
 order by 1,2


 -- Order of Countries with Highest Infection Rate compared to Population

  select location, max(total_cases) as TotalCases, population, (max(total_cases)/population)*100 as InfectionRate
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by location, population
 order by InfectionRate desc


 -- Order of Countries with Highest Death Count compared to Population

 select location, max(convert(int, total_deaths)) as TotalDeathsTillDate, population, (max(convert(int, total_deaths))/population)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths 
 where continent is not null
 group by location, population
 order by DeathPercentage desc


 -- Total Deaths according to Continent

 select continent, max(convert(int, total_deaths)) as TotalDeathsperContinent
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by continent
 order by TotalDeathsperContinent desc


 -- Total cases and deaths per day in the world from the very beginning

 select date, sum(new_cases) as TotalCases, sum(convert(int, new_deaths)) as TotalDeaths, (sum(convert(int, new_deaths))/sum(new_cases))*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by date
 order by date



 -- Toatl cases and Deaths till date in the whole world

 select sum(new_cases) as TotalCases, sum(convert(int, new_deaths)) as TotalDeaths, (sum(convert(int, new_deaths))/sum(new_cases))*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where continent is not null




 -- God Number to judge the Country

  select (max(convert(bigint, cv.total_vaccinations)) / square(max(convert(int, cd.total_deaths))))
* (cv.gdp_per_capita/max(cd.total_cases)) * cv.hospital_beds_per_thousand as GodNumber, cd.location
 from PortfolioProject..CovidVaccinations cv
 join PortfolioProject..CovidDeaths cd
 on cv.location = cd.location
 where cd.continent is not null
 group by cd.location, cv.hospital_beds_per_thousand, cv.gdp_per_capita
 order by GodNumber desc



  -- Creating View for Visualization Purpose on Tableau

 Create View PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated