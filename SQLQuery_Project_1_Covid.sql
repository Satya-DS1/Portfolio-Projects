Select * 
from CovidDeaths 
where continent is not null
order by 2,3

Select * 
from Covidvaccinations
where continent is not null
order by 2,3;

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--  Total deaths vs Total cases in india

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from CovidDeaths where location like 'india' and 
continent is not null
order by 1,2

-- Total cases vs Population (Shows what percentage of population got covid)

Select Location, date, total_cases, population,(total_cases/population)*100 as covid_percentage
from CovidDeaths where location like 'india' and 
continent is not null
order by 1,2

-- Countries with highest infection rate compared to population

Select Location, MAX(total_cases) as Highest_infected_count, population, MAX((total_cases/population))*100 as covid_percentage
from CovidDeaths
where continent is not null
group by location, population
order by covid_percentage desc

-- countries with highest death counts

Select Location, MAX(cast(total_deaths as int)) as Highest_death_count 
from CovidDeaths
where continent is not null
group by location
order by Highest_death_count desc

-- Continents with highest death rate

Select continent, MAX(cast(total_deaths as int)) as Highest_death_count 
from CovidDeaths
where continent is not null
group by continent
order by Highest_death_count desc


Select location, MAX(cast(total_deaths as int)) as Highest_death_count 
from CovidDeaths
where continent is null
group by location
order by Highest_death_count desc

-- Global numbers

Select date, sum(total_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths, 
(sum(cast(total_deaths as int))/sum(total_cases))*100 as Death_percentage
from CovidDeaths 
--where location like 'india' and 
where continent is not null
group by date
order by 1,2

-- Total cases worldwide

Select sum(total_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths, 
(sum(cast(total_deaths as int))/sum(total_cases))*100 as Death_percentage
from CovidDeaths 
--where location like 'india' and 
where continent is not null
order by 1,2


-- No. of vaccination done vs population

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_people_vaccinated
from Coviddeaths dea
join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where  dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, total_people_vaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_people_vaccinated
from Coviddeaths dea
join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where  dea.continent is not null
--order by 2,3
)
select *, (total_people_vaccinated/population)*100 as vac_percent
from popvsvac


-- Temp Table

Drop Table if exists #percent_population_vaccinated

create table #percent_population_vaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
total_people_vaccinated numeric
)

Insert into #percent_population_vaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_people_vaccinated
from Coviddeaths dea
join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
--where  dea.continent is not null
--order by 2,3

select *, (total_people_vaccinated/population)*100 as vac_percent
from #percent_population_vaccinated


-- Creating view to store data for later visualization

create view percent_population_vaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_people_vaccinated
from Coviddeaths dea
join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where  dea.continent is not null
--order by 2,3

select * 
from percent_population_vaccinated