					-- Task -- 
# To analyse the extent of world layoffs
# Data sourced from: https://layoffs.fyi

					-- Data Cleaning --
select *
from layoffs
order by 1;

					-- Removing unnecessary columns --
alter table layoffs
drop column `Source`,
drop column `Date Added`;

					-- Renaming columns --
alter table layoffs
rename column `Location HQ` to `hq`,
rename column `# Laid Off` to `laid_off`,
rename column `%` to `percentage_laid_off`,
rename column `$ Raised (mm)` to `raised_millions`;

					-- Finding duplicates --
with dups as(
select *,
row_number() over (
partition by company, hq, laid_off, date, percentage_laid_off, Industry, Stage, raised_millions, country) as unique_counter
from layoffs)

select * 
from dups
where unique_counter >1;

select *
from layoffs
where company in ('Beyond Meat', 'Cazoo');

					-- Creating new table to store altered data --
create table layoffs_working_sheet
like layoffs;

alter table layoffs_working_sheet
add column `unique_counter` int;

insert layoffs_working_sheet
select *,
row_number() over (
partition by company, hq, laid_off, date, percentage_laid_off, Industry, Stage, raised_millions, country) as unique_counter
from layoffs;

					-- Removing duplicates and unique counter column--
delete
from layoffs_working_sheet
where unique_counter >1;

select *
from layoffs_working_sheet
where unique_counter >1;

alter table layoffs_working_sheet
drop column unique_counter;

select *
from layoffs_working_sheet;

					-- Removing sparse data --
select *
from layoffs_working_sheet
where laid_off = ''
and percentage_laid_off ='';

delete
from layoffs_working_sheet
where laid_off = ''
and percentage_laid_off ='';

					-- Standardising Data --
select distinct hq, country
from layoffs_working_sheet
order by 1;

select distinct t1.hq, t2.country
from layoffs_working_sheet t1
join layoffs_working_sheet t2
	on t1.hq = t2.hq
where t1.hq like '%non-%'
and t1.country like 'united st%'
order by 1;

update layoffs_working_sheet
set country = 'Canada'
where hq like 'Vancouver,Non-%';

select distinct hq, replace(hq, ',Non-U.S.','')
from layoffs_working_sheet
where hq like '%non%';

update layoffs_working_sheet
set hq = replace(hq, ',Non-U.S.','')
where hq like '%non%';

select *
from layoffs_working_sheet
where hq like 'SF Bay Area%'
and country not like 'united%';

update layoffs_working_sheet
set country = 'United States'
where hq like 'SF Bay Area%';

select distinct country
from layoffs_working_sheet
order by 1;

select *
from layoffs_working_sheet
where country = 'UAE';

update layoffs_working_sheet
set country = 'United Arab Emirates'
where country like 'UAE';

					-- Changing data types -- 
alter table layoffs_working_sheet
modify column laid_off int;

update layoffs_working_sheet
set laid_off = null
where laid_off = 0;

select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_working_sheet;

update layoffs_working_sheet
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_working_sheet
modify column `date` date;

update layoffs_working_sheet
set percentage_laid_off = replace(percentage_laid_off, '%','');

update layoffs_working_sheet
set percentage_laid_off = cast(percentage_laid_off as double);

alter table layoffs_working_sheet
modify column percentage_laid_off int;

update layoffs_working_sheet
set percentage_laid_off = null
where percentage_laid_off = 0;

update layoffs_working_sheet
set raised_millions = replace(raised_millions, '$','');

update layoffs_working_sheet
set raised_millions = cast(raised_millions as double);

alter table layoffs_working_sheet
modify column raised_millions int;

update layoffs_working_sheet
set raised_millions = null
where raised_millions = 0;

select *
from layoffs_working_sheet;