/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
-- Creating a table for both the datasets
DROP TABLE IF EXISTS `death`;
CREATE TABLE `death` (
  `iso_code` char(8) NOT NULL,
  `continent` varchar(15) NOT NULL,
  `location` varchar(15) NOT NULL,
  `date` date NOT NULL,
  `population` int NOT NULL,
  `total_cases` int DEFAULT NULL,
  `new_cases` int Default NULL,
  `new_cases_smoothed` float(10) Default NULL,
  `total_deaths` int Default NULL,
  `new_deaths` int Default NULL,
  `new_deaths_smoothed` float Default NULL,
  `total_cases_per_million` float Default NULL,
  `new_cases_per_million` float Default NULL,
  `new_cases_smoothed_per_million` float Default NULL,
  `total_deaths_per_million` float Default NULL,
  `new_deaths_per_million` float Default NULL,
  `new_deaths_smoothed_per_million` float(10) Default NULL,
  `reproduction_rate` float(10) Default NULL,
  `icu_patients` int Default NULL,
  `icu_patients_per_million` float(10) Default NULL,
  `hosp_patients` int Default NULL,
  `hosp_patients_per_million` float(10) Default NULL,
  `weekly_icu_admissions` int Default NULL,
  `weekly_icu_admissions_per_million` float(10) Default NULL,
  `weekly_hosp_admissions` int Default NULL,
  `weekly_hosp_admissions_per_million` float(10) Default NULL
);

DROP TABLE IF EXISTS `vacc`;
CREATE TABLE `vacc` (
  `iso_code` char(8) NOT NULL,
  `continent` varchar(15) ,
  `location` varchar(300) NOT NULL,
  `date` date NOT NULL,
  `population` bigint,
  `total_tests` bigint DEFAULT NULL,
  `new_tests` int Default NULL,
  `total_tests_per_thousand` float Default NULL,
  `new_tests_per_thousand` float Default NULL,
  `new_tests_smoothed` int Default NULL,
  `new_tests_smoothed_per_thousand` float Default NULL,
  `positive_rate` float(15) Default NULL,
  `tests_per_case` float(15) Default NULL,
  `tests_units` char(10) Default NULL,
  `total_vaccinations` bigint Default NULL,
  `people_vaccinated` bigint Default NULL,
  `people_fully_vaccinated` bigint Default NULL,
  `total_boosters` bigint Default NULL,
  `new_vaccinations` int Default NULL,
  `new_vaccinations_smoothed` int Default NULL,
  `total_vaccinations_per_hundred` float Default NULL,
  `people_vaccinated_per_hundred` float Default NULL,
  `people_fully_vaccinated_per_hundred` float Default NULL,
  `total_boosters_per_hundred` float(10) Default NULL,
  `new_vaccinations_smoothed_per_million` int Default NULL,
  `new_people_vaccinated_smoothed` int Default NULL,
  `new_people_vaccinated_smoothed_per_hundred` float(10) Default NULL,
  `stringency_index` float(10) Default NULL,
  `population_density` float(10) Default NULL,
  `median_age` float(10) Default NULL,
  `aged_65_older` float(10) Default NULL,
  `aged_70_older` float(10) Default NULL,
  `gdp_per_capita` float(10) Default NULL,
  `extreme_poverty` float(10) Default NULL,
  `cardiovasc_death_rate` float(10) Default NULL,
  `diabetes_prevalence` float(10) Default NULL,
  `female_smokers` float(10) Default NULL,
  `male_smokers` float(10) Default NULL,
  `handwashing_facilities` float(10) Default NULL,
  `hospital_beds_per_thousand` float(10) Default NULL,
  `life_expectancy` float(10) Default NULL,
  `human_development_index` float(10) Default NULL,
  `excess_mortality_cumulative_absolute` float Default NULL,
  `excess_mortality_cumulative` float Default NULL,
  `excess_mortality` float Default NULL,
  `excess_mortality_cumulative_per_million` float Default NULL
);
use covid;

-- Studying the dataset

select* from death
order by 3,4;
select* from vacc
order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population
from death
order by 1,2;

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from death
Where location = "India"
order by 1,2;

select location,date,total_cases,population, (total_cases/population)*100 as CovidPercentage
from death
order by 1,2;
-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location,population,MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population)*100) as CovidinfectPercentage
from death
group by location,population
order by CovidinfectPercentage desc;

-- Showing Countries with the highest death count per population
select location,MAX(total_deaths)as TotalDeathCount
from death
where continent is not null
group by location
order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

select location,MAX(total_deaths)as TotalDeathCount
from death
where continent is null AND location not like '%income%' 
and location not in ('world','European Union','International')
group by location 
order by TotalDeathCount desc;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select date,SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,(SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
from death
where continent is not null
-- group by date 
order by 1,2;


-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select d.continent,d.location,d.date,d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (partition by d.location order by d.location,d.Date) 
as RollingPeopleVaccinated
from death d
join vacc v
	on d.location = v.location
    and d.date = v.date
where d.continent is not null
order by 2,3
)

select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac
where new_vaccinations is not null;

-- Creating View to store data for later visualizations
Create view PercentPopulationVaccinated as 
select d.continent,d.location,d.date,d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (partition by d.location order by d.location,d.Date) 
as RollingPeopleVaccinated
from death d
join vacc v
	on d.location = v.location
    and d.date = v.date
where d.continent is not null
order by 2,3;
-- Cheking Final Data
select * from PercentPopulationVaccinated