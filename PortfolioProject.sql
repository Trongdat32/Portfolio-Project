create database [Portfolio project]

use [Portfolio project]

select *
from [Portfolio project]..CovidDeath
where continent is not null
order by 3,4  --sắp xếp kết quả theo cột thứ 3 và cột thứ 4 của bảng dữ liệu.

--select * 
--from [Portfolio project]..CovidVaccination
--order by 3,4

--Select data we're going to be using 
select [location], [date], total_cases,new_cases,total_deaths,[population]
from [Portfolio project]..CovidDeath
order by 1,2



--Looking at Total Cases vs Total Deaths 
--Xác suất tử vong nếu nhiễm Covid-19 ở quốc gia của bạn.
alter table dbo.CovidDeath
alter column total_deaths decimal
alter column total_cases decimal

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeath
where location like '%state%'			--Áp dụng điều kiện lọc dữ liệu,chỉ chọn các bản ghi có giá trị trong cột "location" chứa chuỗi "state".Dấu "%" đại diện cho một chuỗi bất kỳ.
order by 1,2

--Looking at Total Cases vs Population
select Location, date, total_cases, Population, (total_cases/population)*100 as DeathPercentage
from [Portfolio project]..CovidDeath
--where location like '%state%'
order by 1,2


--Looking at country wwith highest infection rate compared to Population
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio project]..CovidDeath
group by location,population
order by PercentPopulationInfected desc

--Phan tich các quốc gia có số ca tử vong cao nhất theo tỷ lệ dân số.
select Location, Max(total_deaths) as TotalDeathCount
from [Portfolio project]..CovidDeath
where continent is not null 
group by location
order by TotalDeathCount desc


--Phan tich theo Chau luc
select continent, Max(total_deaths) as TotalDeathCount
from [Portfolio project]..CovidDeath
where continent is null 
group by continent
order by TotalDeathCount desc


--Phan tich theo khu vuc
select location, Max(total_deaths) as TotalDeathCount
from [Portfolio project]..CovidDeath
where continent is null 
group by location
order by TotalDeathCount desc

--Xuat ra cac quoc gia co so ca tu vong cao theo ti le dan so 
select continent, Max(total_deaths) as TotalDeathCount
from [Portfolio project]..CovidDeath
where continent is not null 
group by continent
order by TotalDeathCount desc



SELECT Location,continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [Portfolio project]..CovidDeath
where location like '%state%'
and continent is not null 
order by 1,2

--Global numbers 
SELECT date, Sum(new_cases) AS 'So ca nhiem moi', Sum(CAST(new_deaths as int)) as 'So ca tu vong moi' ,
Sum(CAST(new_deaths as int))/NULLIF(Sum(new_cases),0) * 100 as 'Ti le tu vong'
--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [Portfolio project]..CovidDeath
--where location like '%state%'

where continent is not null 
group by date	
order by 1,2


--USE CTE (Common table Expression- bảng temp)
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
--Looking at total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations )) over (Partition by dea.Location order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeath dea
join [Portfolio project]..CovidVaccination vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for visualization 
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations )) over (Partition by dea.Location order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeath dea
join [Portfolio project]..CovidVaccination vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 


Select *
From PercentPopulationVaccinated
