
-- athletes - id	name	sex	height	weight	team
-- athlete_events - athlete_id	games	year	season	city	sport	event	medal

--1. How many unique athletes have participated in the Olympics?
select count(distinct(id)) as unique_athletes
from athletes ;

--2. What is the distribution of male and female athletes in the dataset?
select sex, count(*) as distribution
from athletes
group by sex;

--3. List all gold medalists in a specific year and sport.
select a.name
from athletes a 
inner join athlete_events ae 
on a.id = ae.athlete_id
where year = '<>'
and sport = '<>'
and medal = 'Gold'
;

--4. What is the average height and weight of male and female athletes?
select sex, avg(height) as avg_height, avg(weight) as avg_weight
from athletes
group by sex;

--5 Which country has the highest number of Olympic medals in a specific year?
select city, max(count(medal)) as highest_medal_count
from athlete_events
where year = '<>'
group by city
order by highest_medal_count desc
limit 1;

--6 List all athletes who have won at least one gold medal.
select a.name
from athletes a 
inner join athlete_events ae 
on a.id = ae.athlete_id
where medal = 'Gold'

--7 Find the most popular sport in terms of the number of athletes who participated.
select sport, count(distinct athlete_id) as total_athlete_per_sport
from athlete_events
group by sport
order by total_athlete_per_sport DESC
LIMIT 1;

--8 How many athletes participated in both the Summer and Winter Olympics?
select count(distinct athlete_id) as participants
from athlete_events
where season in ('Summer', 'Winter')
group by athlete_id
having count(distinct season)=2 ;

--9 List the cities that have hosted the Olympics more than once.
select city, count(distinct year) as total_hosted_years
from athlete_events
group by city 
having total_hosted_years>1;

--10 Which athlete has the highest total number of medals (gold, silver, and bronze) in their career?
select a.athlete_id, a.name , count(*) as total_medals
from athletes a 
inner join athlete_events ae 
on a.id = ae.athlete_id
where medal is NOT NULL
group by a.athlete_id, a.name
order by total_medals DESC
LIMIT 1;


-- athletes - id	name	sex	height	weight	team
-- athlete_events - athlete_id	games	year	season	city	sport	event	medal

--11. Which team has won the maximum gold medals over the years.
select a.team, count(ae.medal) as gold_medals_won
from athletes a 
inner join athlete_events ae 
on a.id = ae.athlete_id
where ae.medal = 'Gold'
group by a.team
order by gold_medals_won desc
limit 1;

--12. for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver.

select 
    a.team,
    COUNT(case when e.medal = 'Silver' then 1 end) as total_silver_medals,
    MAX(case when e.medal = 'Silver' then e.year end) as year_of_max_silver
from
    athletes a
left join
    athlete_events e on a.id = e.athlete_id
group by
    a.team;

--13.which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years.

select a.name, sum(ae.medal) as gold_medals_won
from athletes a 
inner join athlete_events ae 
on a.id = ae.athlete_id 
and ae.medal = 'Gold'
where 
a.id not in (select athlete_id 
            from athlete_events
            where medal in ('Bronze','Silver'))
group by a.id, a.name 
order by gold_medals_won desc
limit 1;

--14 In each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

with cte as
(
  select a.name as player_name, 
        ae.year,
        count(ae.medal) as total_gold_medals
  from athletes a 
  inner join athlete_events ae 
  on a.id = ae.athlete_id 
  and ae.medal = 'Gold'
  group by ae.year, a.name
)
select year,
  string_agg(player_name, ', ') as player_names,
  max(total_gold_medals) as max_gold_medals
from cte 
group by year 
order by year

--15.In which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport. 

select distinct * from (
select medal,year,event,rank() over(partition by medal order by year) rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where team='India' and medal != 'NA'
) A
where rn=1;

