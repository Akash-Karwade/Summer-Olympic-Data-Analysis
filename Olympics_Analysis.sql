Create database Projects;
use projects;

LOAD DATA infile 'C:/ProgramData/MySQL/MySQL Server 9.0/Uploads/olympics_dataset.csv'
INTO Table olympics
fields terminated by ','
optionally enclosed by '"'
ignore 1 lines;

select * from olympics;

# find and delete duplicate rows
/*select distinct Name,Year,Season,City,Event,Medal,
count(*) from olympics 
group by Name,Year,Season,City,Event,Medal 
having count(*)>1 ;*/
SET SQL_SAFE_UPDATES = 0; #Disable safe mode to perform delete operations

Delete from olympics
where Name IN (SELECT Name from (
Select Name,Year,Season,City,Event,Medals, 
row_number() over (partition by Name,Year,Season,City,Event,Medals)
as Row_num from olympics) as Temp
where Row_num > 1);

# number of countries participated in olympics
select count(distinct NOC) as Total_countries from olympics;

# List of Total no. of males and females participated by gender
Select sex, count(*) as Total_no 
from olympics
group by sex;

/* List of Total no. of males and females participated by city, country.
A query that also computes the male and female gender ratio in each city and country. */

SELECT Team, NOC as ContryCode,
COUNT(*) AS total_No, 
SUM(CASE WHEN LOWER(Sex) = 'm' THEN 1 ELSE 0 END) AS Male, 
SUM(CASE WHEN LOWER(Sex) = 'f' THEN 1 ELSE 0 END) AS Female,
SUM(CASE WHEN LOWER(Sex) = 'm' THEN 1 ELSE 0 END) / 
SUM(CASE WHEN LOWER(Sex) = 'f' THEN 1 ELSE 0 END) 
AS Sex_Ratio
FROM olympics
GROUP BY NOC,Team
ORDER BY total_No DESC
LIMIT 20;

# no. of medals won by male and female (gold, silver, bronze)

SELECT Sex,
SUM(CASE WHEN LOWER(Medals)  like '%Gold%' THEN 1 ELSE 0 END) AS Gold,
SUM(CASE WHEN LOWER(Medals) like '%Silver%' THEN 1 ELSE 0 END) AS Silver,
SUM(CASE WHEN LOWER(Medals) like '%Bronze%' THEN 1 ELSE 0 END) AS Bronze
From olympics
WHERE Medals IS NOT NULL
GROUP BY Sex;

# no of Gold medals won by county, top 5 countries

SELECT Team, count(*)
From olympics
WHERE Medals LIKE '%Gold%' 
GROUP BY Team
ORDER BY Team DESC
LIMIT 5;

# list of participant from each country sorted by season by top 10 countries
SELECT Team, Season, count(*) AS Total_Participant
FROM olympics
GROUP BY Team, Season
ORDER BY Total_Participant DESC, Season
LIMIT 10;

# list of county won highest no of medals and in which year

SELECT Team, year, count(medals) AS Medals
FROM olympics
WHERE Medals LIKE '%Gold%' 
   OR Medals LIKE '%Silver%' 
   OR Medals LIKE '%Bronze%'
GROUP BY Team, year
ORDER BY Medals DESC
LIMIT 10;

# No of highest medals won in particular game by a country
SELECT Team AS CountryCode, Sport, COUNT(*) AS TotalMedals
FROM olympics
WHERE Medals LIKE '%Gold%' 
   OR Medals LIKE '%Silver%' 
   OR Medals LIKE '%Bronze%'
GROUP BY Team, Sport
ORDER BY TotalMedals DESC;

# No of partcipations by female yearly

# Medals gold attained in 2024
SELECT Team, Year,count(medals) as Total_Golds
FROM olympics
WHERE Medals like "%Gold%" AND year = 2024
GROUP BY Team, year
ORDER BY Total_Golds DESC
LIMIT 10;

# No of participants in season wise
SELECT Season, count(*) as Participants
FROM olympics
GROUP BY Season
ORDER BY Participants DESC;

# The City most sutaible for multiple games to be played
SELECT City, count(*) as Total_games_Played
FROM olympics
GROUP BY City
ORDER BY Total_games_Played DESC;

# Most Popular sports for women participants by Sex	
With Ranking as (
SELECT Sport , Event,Sex, count(*) as Game_Count, 
Rank() over (partition by Sex order by count(*) DESC) 
AS RANKED
FROM olympics 
GROUP BY Sport, Event, Sex)
SELECT Sport , Event,Sex, Game_Count
FROM Ranking
WHERE RANKED <=3
ORDER BY Sex, Game_Count DESC;

# which player have won maximum medals
SELECT name,Team, count(medals) as No_of_medals
from olympics
WHERE Medals LIKE '%Gold%' 
   OR Medals LIKE '%Silver%' 
   OR Medals LIKE '%Bronze%'
GROUP BY name,Team
ORDER BY No_of_medals DESC;

# which sport has maximum events
# which year has maximum events


