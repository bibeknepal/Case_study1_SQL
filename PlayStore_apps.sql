create database Data;
CREATE TABLE playstore_apps (
  app_name TEXT,
  category TEXT,
  rating REAL,
  rating_count REAL,
  maximum_installs INTEGER,
  free INTEGER,
  price REAL,
  currency TEXT,
  size REAL,
  released TIMESTAMP,
  content_rating TEXT
);


select count(*) from playstore_apps;

-- Take a look at all app’s names, their categories, and their release dates from the table.
select app_name,category,released
from playstore_apps;

-- Take a look at everything in the first 10 rows of the table.

select *
from playstore_apps
limit 10;

-- Take a look at everything in the 31st-45th row of the table.

select * 
from playstore_apps
limit 30,15;

-- Select app name, rating counts and release column, and rename them to “APP”, “Rating Count” & “release_time” respectively.

select app_name as "APP",
rating_count as  "Rating Count",
released as "release_time"
from playstore_apps;

--  List all categories in this table.

select distinct(category) from playstore_apps;

-- List all categories + content rating pairs in this table.

select distinct category, rating
from playstore_apps;

--  List all entertainment apps that are not rated by everyone.

SELECT * 
FROM playstore_apps 
WHERE category = 'Entertainment'
AND content_rating != 'Everyone';

-- List all non-entertainment and non-education apps that are rated by everyone or teen.


select * 
from playstore_apps
where category not in ("Entertainment","Education")
and content_rating in ("Everyone","Teen");

-- List all apps whose app names contain the letter “i” or start with the letter “d”.
select app_name 
from playstore_apps
where app_name like "%i%" or app_name like "d%";
select * from playstore_apps;

-- List all apps whose app names contain a 3-letter word with character ‘a’ in the middle (e.g. cat, map, max).
select * from playstore_apps
where app_name like "_a_";

-- List apps that have at least a rating (i.e. rating_count > 0)
-- and whose install count are no more than 1000 
-- and size between 10 and 20 (included).
select * from playstore_apps
where rating_count > 0 
and maximum_installs <= 1000
and size between 10 and 20;

-- List all sports apps and order them by size in ascending order.
--  If they have the same size, order them by rating counts in descending order.
select * from playstore_apps
where category = "Sports"
order by size,rating_count desc;

-- Return the app names, categories, sizes, release dates (rename it to “Release Dates”)
--  of apps whose app names have more than 1 word,
--  and whose categories are music and social,
-- and whose sizes are bigger than 10.
-- Order the output result by maximum installs in descending order, then release dates in ascending order.

select app_name, category,size,released as "Release Dates"
from playstore_apps
where app_name like "% %"
and category in ("Music","Social")
and size> 10
order by maximum_installs desc, released;

-- List the app names and their release years, release months, and release days.
select app_name,date(released) as release_date,
year(released) as release_year,
month(released) as release_month,
day(released) as release_day
from playstore_apps
order by release_year;

-- Calculate the duration since the release dates of these apps until today in 2 formats:
-- days only and year/month/day. 
-- Return the app names, release dates and their corresponding durations.

SELECT
  app_name,
  released,
  current_date(),
  DATEDIFF(CURDATE(), released) AS duration_in_days,
  CONCAT(
    FLOOR(DATEDIFF(current_date(), released) / 365), ' years ',
    FLOOR((DATEDIFF(current_date(), released) % 365) / 30), ' months ',
    (DATEDIFF(current_date(), released) % 30), ' days'
  ) AS duration_in_ymd
FROM
  playstore_apps;

-- Create a column called “release_after_3_hours” which adds 3 hours to the release dates of the app.
-- Return the app names, release dates, and this new column
select app_name, released as "release dates" ,
date_add(released, interval 3 hour)  release_after_3_hours
from playstore_apps;

-- count the number of unique categories in the table 
select count(distinct category) from playstore_apps;

-- Calculate the average rating and total rating count of all apps.

select avg(rating) as average_rating , sum(rating) as total_rating
from playstore_apps;

-- Calculate number of days between the earliest release to the latest release in this table.
select datediff(max(released),min(released)) from 
playstore_apps;


-- select largest app size within each category
select category,max(size)
from playstore_apps
group by category;

-- Find all app categories that have an average rating count bigger than 3.
select category, avg(rating_count)
from playstore_apps
group by category
having avg(rating_count) >3;

--  Count the number of apps released in each year after 2013 and order by year in ascending order.
select * from playstore_apps;
select year(released),count(*) 
from playstore_apps
where year(released) > 2013
group by  year(released)
order by year(released);

-- 
