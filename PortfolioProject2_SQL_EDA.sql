					-- Task -- 
# To analyse the extent of world layoffs
# Data sourced from: https://layoffs.fyi

					-- EDA


					-- Temporal Analysis
					-- looking at yearly trends
select year(date), count(*) as occurrences, sum(laid_off)
from layoffs_working_sheet
group by 1
order by 1;

					-- looking at monthly trends
select date_format(date, '%Y.%m') as month_year, count(laid_off) as occurrences, sum(laid_off)
from layoffs_working_sheet
group by 1, year(date), month(date)
order by year(date), month(date);

					-- looking at the most number of people laid off on a single date
select date, laid_off, percentage_laid_off
from layoffs_working_sheet
order by 2 desc
limit 10;


					-- Sector Analysis
					-- looking at which industries was affected the most overall
select industry, sum(laid_off)
from layoffs_working_sheet
group by 1
order by 2 desc;

					-- looking at the top 5 affected sectors each year
with annual_layoffs as (
	select year(date) as year, industry, count(*) as occurrences, sum(laid_off) as total_laid_off,
		rank() over (partition by year(date) 
		order by sum(laid_off) desc) as sector_rank
	from layoffs_working_sheet
    where industry != ''
    and laid_off is not null
    group by year(date), industry)
select year, industry, occurrences, total_laid_off
from annual_layoffs
where sector_rank <= 5
and industry != 'Other'
order by year,total_laid_off desc;

					-- Yearly change per sector
with annual_layoffs as (
    select
        year(date) as year,
        industry,
        count(*) as occurrences,
        sum(laid_off) as total_laid_off
    from layoffs_working_sheet
    where industry is not null
    group by year(date), industry
)
select 
    year,
    industry,
    occurrences,
    total_laid_off,
    total_laid_off - lag(total_laid_off, 1) over (partition by industry order by year) as yearly_change
from annual_layoffs
where industry != ''
order by industry, year;

					-- looking at how many companies from each sector went under per year, and the sum of employees laid off by sector
select year(date) as year, industry, count(company) as companies_shut, sum(laid_off)
from layoffs_working_sheet
where percentage_laid_off =100 
group by 1, 2
order by 1,3 desc;


					-- Geographic Analysis
					-- looking at countries with the most layoffs
select country, sum(laid_off)
from layoffs_working_sheet
group by 1
order by 2 desc
limit 10;

					-- looking at locations with the most layoffs
select hq, country, sum(laid_off)
from layoffs_working_sheet
group by 1,2
order by 3 desc
limit 10;


					-- Company specific insights
					-- looking at the companies with the most total layoffs
select company, sum(laid_off)
from layoffs_working_sheet
group by 1
order by 2 desc
limit 10;

					-- looking at the companies that had the highest percentage laid off without going under
select distinct company, max(percentage_laid_off), max(laid_off)
from layoffs_working_sheet
where percentage_laid_off != 100
group by 1
order by 2 desc;

					-- looking at which funding stage had the most layoffs
select stage, count(*) as occurrences, sum(laid_off)
from layoffs_working_sheet
where stage != '' and stage != 'unknown'
group by 1
order by 3 desc;

					-- comparing post-ipo and startup companies layoff trends
select stage, count(distinct company), round(avg(percentage_laid_off)) as avg_percentage_laid_off
from layoffs_working_sheet
where stage in ('post-ipo', 'seed')
group by stage
order by 3 desc;