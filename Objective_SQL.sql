												-- Objective Questions --

-- Q2 ) What is the total number of runs scored in 1st season by RCB (bonus: also include the extra runs using the extra runs table)

SELECT 
    SUM(b.Runs_Scored + COALESCE(e.Extra_Runs, 0)) AS Total_Runs
FROM ball_by_ball b
JOIN matches m ON b.Match_Id = m.Match_Id
JOIN team t ON b.Team_Batting = t.Team_Id
LEFT JOIN extra_runs e 
    ON b.Match_Id = e.Match_Id 
    AND b.Over_Id = e.Over_Id 
    AND b.Ball_Id = e.Ball_Id 
    AND b.Innings_No = e.Innings_No
WHERE m.Season_Id = 1 AND t.Team_Name = "Royal Challengers Bangalore";


-- Q3) How many players were more than the age of 25 during season 2014?

select 
	count(distinct pm.Player_id ) as Older_Than_25
from  Matches m 
join Player_Match pm on m.Match_ID = pm.Match_ID
join Player p on pm.Player_Id = p.Player_Id
where m.Season_Id = 7
and timestampdiff(Year, p.DOB, m.Match_Date) > 25;



-- Q4) How many matches did RCB win in 2013? 

select
	count(*) As Total_Win_By_RCB
from Matches m 
join Season s on m.Season_Id = s.Season_Id
where s.Season_Id = 6 and m.Match_Winner = 2;


-- Q5) List the top 10 players according to their strike rate in the last 4 seasons

SELECT 
    p.Player_Name,
    SUM(bbb.Runs_Scored) AS Total_Runs,
    COUNT(*) AS Balls_Faced,
    ROUND(SUM(bbb.Runs_Scored) * 100.0 / COUNT(*), 2) AS Strike_Rate
FROM 
    ball_by_ball bbb
JOIN matches m ON bbb.Match_Id = m.Match_Id
JOIN season s ON m.Season_Id = s.Season_Id
JOIN player p ON bbb.Striker = p.Player_Id
WHERE s.Season_Year >= (
        SELECT MAX(Season_Year) - 3 FROM season
    )
GROUP BY p.Player_Name
HAVING COUNT(*) >= 20 -- optional filter: at least 20 balls faced
ORDER BY Strike_Rate DESC
LIMIT 10;




-- Q6) What are the average runs scored by each batsman considering all the seasons?

select 
	Player_Id,
    avg(Runs_Scored) as Total_RS
from ball_by_ball b
left join player_match pm on b.Match_Id = pm.Match_Id
group by Player_Id
order by Player_Id;


-- Q7) What are the average wickets taken by each bowler considering all the seasons?

SELECT 
    p.Player_Name,
    s.Season_Year,
    COUNT(DISTINCT CONCAT(wt.Match_Id, '-', wt.Over_Id, '-', wt.Ball_Id)) AS Total_Wickets,
    COUNT(DISTINCT b.Match_Id) AS Matches_Played,
    ROUND(
        COUNT(DISTINCT CONCAT(wt.Match_Id, '-', wt.Over_Id, '-', wt.Ball_Id)) / 
        COUNT(DISTINCT b.Match_Id), 2
    ) AS Avg_Wickets_Per_Match
FROM 
    ball_by_ball b
JOIN wicket_taken wt 
    ON b.Match_Id = wt.Match_Id 
    AND b.Over_Id = wt.Over_Id 
    AND b.Ball_Id = wt.Ball_Id
JOIN matches m ON b.Match_Id = m.Match_Id
JOIN season s ON m.Season_Id = s.Season_Id
JOIN player p ON b.Bowler = p.Player_Id
WHERE 
    wt.Kind_Out IS NOT NULL
GROUP BY 
    p.Player_Name, s.Season_Year
ORDER BY 
    p.Player_Name, s.Season_Year;





-- Q8) List all the players who have average runs scored greater than the overall average and who have taken wickets greater than the overall average

with Player_wise_runs_avg as (
select 
	bb.Striker,
	Avg(Runs_Scored) as PlayerAvg
from ball_by_ball as bb
join wicket_taken as wt on bb.Match_Id = wt.Match_Id and  bb.Innings_No = wt.Innings_No and bb.Over_Id = wt.Over_Id and bb.Ball_Id = wt.Ball_Id
group by bb.Striker
order by bb.Striker
),
Player_wise_wicket_taken as (select 
	bb.Bowler,
    Count(*) as perBowlerWicketTaken
from ball_by_ball as bb
join wicket_taken as wt on bb.Match_Id = wt.Match_Id and  bb.Innings_No = wt.Innings_No and bb.Over_Id = wt.Over_Id and bb.Ball_Id = wt.Ball_Id
group by bb.Bowler
order by bb.Bowler),

overal as (select
	avg(Runs_Scored) Total_avg,
    avg(pt.perBowlerWicketTaken) total_bollwing_avg
from ball_by_ball as bb
join wicket_taken as wt on bb.Match_Id = wt.Match_Id and  bb.Innings_No = wt.Innings_No and bb.Over_Id = wt.Over_Id and bb.Ball_Id = wt.Ball_Id
join Player_wise_wicket_taken pt)

select
	pa.Striker
from  Player_wise_runs_avg as pa
join Player_wise_wicket_taken as pt on pa.Striker = pt.Bowler
join overal as o
where PlayerAvg > Total_avg and perBowlerWicketTaken > total_bollwing_avg
order by pa.striker;


-- Q9) Create a table rcb_record table that shows the wins and losses of RCB in an individual venue.

CREATE TABLE rcb_record AS
SELECT 
    v.Venue_Id,
    SUM(CASE WHEN m.Match_winner = 2 THEN 1 ELSE 0 END) AS Wins,
    SUM(CASE WHEN m.Match_winner != 2 AND (m.Team_1 = 2 OR m.Team_2 = 2) THEN 1 ELSE 0 END) AS Losses
FROM matches m
JOIN venue v ON m.Venue_id = v.Venue_id
WHERE m.Team_1 = 2 OR m.Team_2 = 2
GROUP BY v.Venue_Id;


-- Q10) What is the impact of bowling style on wickets taken?

select 
	bs.Bowling_skill,
	COUNT(wt.Player_Out) AS Wicket_taken
from ball_by_ball as bb
join wicket_taken as wt on bb.Match_Id = wt.Match_Id and  bb.Innings_No = wt.Innings_No and bb.Over_Id = wt.Over_Id and bb.Ball_Id = wt.Ball_Id
join player as p on bb.Bowler = p.Player_Id
join bowling_style as bs on p.Bowling_skill = bs.Bowling_Id
group by bs.Bowling_skill;


-- Q11) Write the SQL query to provide a status of whether the performance of the team is better than the previous year's 
-- performance on the basis of the number of runs scored by the team in the season and the number of wickets taken 

WITH Team_Performance AS (
    SELECT 
        t.Team_Id,
        t.Team_Name,
        s.Season_Year,
        SUM(bb.Runs_Scored) AS Total_Runs,
        COUNT(DISTINCT wt.Player_Out) AS Total_Wickets
    FROM matches AS m
    JOIN season AS s ON m.Season_Id = s.Season_Id
    JOIN team AS t ON (m.Team_1 = t.Team_Id OR m.Team_2 = t.Team_Id)
    JOIN ball_by_ball AS bb ON m.Match_Id = bb.Match_Id
    LEFT JOIN wicket_taken AS wt ON bb.Match_Id = wt.Match_Id 
                                AND bb.Innings_No = wt.Innings_No 
                                AND bb.Over_Id = wt.Over_Id 
                                AND bb.Ball_Id = wt.Ball_Id
    GROUP BY t.Team_Id, t.Team_Name, s.Season_Year
),
Performance_Comparison AS (
    SELECT 
        tp1.Team_Id,
        tp1.Team_Name,
        tp1.Season_Year,
        tp1.Total_Runs AS Current_Season_Runs,
        tp1.Total_Wickets AS Current_Season_Wickets,
        tp2.Total_Runs AS Previous_Season_Runs,
        tp2.Total_Wickets AS Previous_Season_Wickets,
        CASE 
            WHEN tp1.Total_Runs < tp2.Total_Runs AND tp1.Total_Wickets < tp2.Total_Wickets THEN 'Worse'
            WHEN tp1.Total_Runs > tp2.Total_Runs AND tp1.Total_Wickets > tp2.Total_Wickets THEN 'Better'
            ELSE 'Same'
        END AS Performance_Status
    FROM Team_Performance tp1
    LEFT JOIN Team_Performance tp2 
        ON tp1.Team_Id = tp2.Team_Id 
        AND tp1.Season_Year = tp2.Season_Year + 1
)
SELECT * FROM Performance_Comparison;



-- Q12 ) Can you derive more KPIs for the team strategy?

-- select
-- 	*
-- from season as s
-- join matches as m on s.Season_Id  = m.Season_Id
-- join ball_by_ball as bb on m.Match_Id = bb.Match_Id
-- join extra_runs as ex on m.Match_Id = ex.Match_Id 
-- join wicket_taken as wt on m.Match_Id = wt.Match_Id;

WITH Player_wise_wicket_taken AS (
    SELECT
        wt.Match_Id,
        bb.Over_Id,
        bb.Bowler,
        COUNT(*) AS perBowlerWicketTaken
    FROM ball_by_ball AS bb
    JOIN wicket_taken AS wt 
        ON bb.Match_Id = wt.Match_Id 
        AND bb.Innings_No = wt.Innings_No 
        AND bb.Over_Id = wt.Over_Id 
        AND bb.Ball_Id = wt.Ball_Id
    GROUP BY bb.Bowler, wt.Match_Id, bb.Over_Id
),

Player_wise_runs_avg AS (
    SELECT 
        bb.Match_Id,
        bb.Over_Id,
        bb.Striker,
        SUM(bb.Runs_Scored) / COUNT(DISTINCT bb.Match_Id) AS PlayerAvg
    FROM ball_by_ball AS bb
    GROUP BY bb.Striker, bb.Match_Id, bb.Over_Id
)

SELECT 
    pa.Match_Id,
    pa.Over_Id,
    pa.Striker,
    pa.PlayerAvg,
    pt.Bowler,
    pt.perBowlerWicketTaken
FROM Player_wise_runs_avg AS pa
JOIN Player_wise_wicket_taken AS pt 
    ON pa.Match_Id = pt.Match_Id 
    AND pa.Over_Id = pt.Over_Id
ORDER BY pa.Match_Id, pa.Over_Id;


    
    
-- Q13 ) Using SQL, write a query to find out the average wickets taken by each bowler in each venue. 
-- Also, rank the gender according to the average value.

WITH Bowler_Avg_Wickets AS (
    SELECT 
        p.Player_Id,
        p.Player_Name,
        v.Venue_Name,
        COUNT(wt.Player_Out) / COUNT(DISTINCT m.Match_Id) AS Avg_Wickets
    FROM ball_by_ball AS bb
    JOIN wicket_taken AS wt 
        ON bb.Match_Id = wt.Match_Id 
        AND bb.Innings_No = wt.Innings_No 
        AND bb.Over_Id = wt.Over_Id 
        AND bb.Ball_Id = wt.Ball_Id
    JOIN player AS p ON bb.Bowler = p.Player_Id
    JOIN matches AS m ON bb.Match_Id = m.Match_Id
    JOIN venue AS v ON m.Venue_Id = v.Venue_Id
    GROUP BY p.Player_Id, p.Player_Name, v.Venue_Name
)
SELECT 
    Player_Id,
    Player_Name,
    Venue_Name,
    Avg_Wickets,
    row_number() OVER (ORDER BY Avg_Wickets DESC) AS Wicket_Rank
FROM Bowler_Avg_Wickets
ORDER BY Wicket_Rank;
    
    
-- Q14) Which of the given players have consistently performed well in past seasons? (will you use any visualization to solve the problem)

SELECT 
    pm.Player_Id, 
    p.Player_Name, 
    s.Season_Year, 
    SUM(b.Runs_Scored) AS Total_Runs
FROM ball_by_ball b
JOIN player_match pm ON b.Match_Id = pm.Match_Id AND b.Striker = pm.Player_Id
JOIN matches m ON b.Match_Id = m.Match_Id
JOIN season s ON m.Season_Id = s.Season_Id
JOIN player p ON pm.Player_Id = p.Player_Id
GROUP BY pm.Player_Id, p.Player_Name, s.Season_Year
ORDER BY pm.Player_Id, s.Season_Year;

SELECT 
    w.Bowler AS Player_Id, 
    p.Player_Name, 
    s.Season_Year, 
    COUNT(*) AS Total_Wickets
FROM wicket_taken w
JOIN matches m ON w.Match_Id = m.Match_Id
JOIN season s ON m.Season_Id = s.Season_Id
JOIN player p ON w.Bowler = p.Player_Id
GROUP BY w.Bowler, p.Player_Name, s.Season_Year
ORDER BY w.Bowler, s.Season_Year;

SELECT 
    m.Man_of_the_match AS Player_Id, 
    p.Player_Name, 
    s.Season_Year, 
    COUNT(*) AS MOM_Awards
FROM matches m
JOIN season s ON m.Season_Id = s.Season_Id
JOIN player p ON m.Man_of_the_match = p.Player_Id
GROUP BY m.Man_of_the_match, p.Player_Name, s.Season_Year
ORDER BY MOM_Awards DESC, s.Season_Year;


WITH Batting AS (
    SELECT pm.Player_Id, p.Player_Name, s.Season_Year, SUM(b.Runs_Scored) AS Total_Runs
    FROM ball_by_ball b
    JOIN player_match pm ON b.Match_Id = pm.Match_Id AND b.Striker = pm.Player_Id
    JOIN matches m ON b.Match_Id = m.Match_Id
    JOIN season s ON m.Season_Id = s.Season_Id
    JOIN player p ON pm.Player_Id = p.Player_Id
    GROUP BY pm.Player_Id, p.Player_Name, s.Season_Year
),
Bowling AS (
    SELECT wt.Player_Out AS Player_Id, p.Player_Name, s.Season_Year, COUNT(*) AS Total_Wickets
    FROM wicket_taken wt
    JOIN matches m ON wt.Match_Id = m.Match_Id
    JOIN season s ON m.Season_Id = s.Season_Id
    JOIN player p ON wt.Player_Out = p.Player_Id
    GROUP BY wt.Player_Out, p.Player_Name, s.Season_Year
)
SELECT 
    b.Player_Id, 
    b.Player_Name, 
    COUNT(DISTINCT b.Season_Year) AS Seasons_Above_Threshold
FROM (
    SELECT Player_Id, Player_Name, Season_Year FROM Batting WHERE Total_Runs > 400
    UNION ALL
    SELECT Player_Id, Player_Name, Season_Year FROM Bowling WHERE Total_Wickets > 15
) b
GROUP BY b.Player_Id, b.Player_Name
HAVING COUNT(DISTINCT b.Season_Year) >= 3
ORDER BY Seasons_Above_Threshold DESC;


-- Q15) Are there players whose performance is more suited to specific venues or conditions? (how would you present this using charts?) 

SELECT
    p.Player_Name,
    v.Venue_Name,
    SUM(bbb.Runs_Scored) AS Total_Runs,
    COUNT(*) AS Balls_Faced,
    ROUND(SUM(bbb.Runs_Scored) * 1.0 / COUNT(*), 2) AS Strike_Rate
FROM ball_by_ball bbb
JOIN matches m ON bbb.Match_Id = m.Match_Id
JOIN venue v ON m.Venue_Id = v.Venue_Id
JOIN player p ON bbb.Striker = p.Player_Id
GROUP BY p.Player_Name, v.Venue_Name
HAVING COUNT(*) >= 10  -- Filter to ensure minimum balls faced
ORDER BY p.Player_Name, Total_Runs DESC;













    
    



