												-- Subjective Questions--
                                                
-- Q1) How does the toss decision affect the result of the match? 
-- (which visualizations could be used to present your answer better) And is the impact limited to only specific venues?

SELECT 
    v.Venue_Name,
    td.Toss_Name AS Toss_Decision,
    COUNT(*) AS Total_Matches,
    SUM(CASE WHEN m.Toss_winner = m.Match_winner THEN 1 ELSE 0 END) AS Wins_After_Toss,
    ROUND(
        SUM(CASE WHEN m.Toss_winner = m.Match_winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS Win_Percentage
FROM  matches m
JOIN toss_decision td ON m.Toss_Decide = td.Toss_Id
JOIN venue v ON m.Venue_Id = v.Venue_Id
GROUP BY v.Venue_Name, td.Toss_Name
ORDER BY v.Venue_Name, Win_Percentage DESC;


-- Q2) Suggest some of the players who would be best fit for the team.

SELECT 
    p.Player_Name,
    COUNT(*) AS Balls_Faced,
    SUM(bbb.Runs_Scored) AS Total_Runs,
    ROUND(SUM(bbb.Runs_Scored) * 1.0 / COUNT(*), 2) AS Strike_Rate
FROM ball_by_ball bbb
JOIN matches m ON bbb.Match_Id = m.Match_Id
JOIN season s ON m.Season_Id = s.Season_Id
JOIN player p ON bbb.Striker = p.Player_Id
WHERE s.Season_Year >= (SELECT MAX(Season_Year) - 3 FROM season)
GROUP BY p.Player_Name
HAVING COUNT(*) >= 50 -- minimum balls faced
ORDER BY Strike_Rate DESC, Total_Runs DESC
LIMIT 10;

SELECT 
    p.Player_Name,
    COUNT(*) AS Balls_Bowled,
    COUNT(wt.Player_out) AS Wickets,
    ROUND(COUNT(wt.Player_out) * 1.0 / COUNT(*), 2) AS Wicket_Per_Ball
FROM ball_by_ball bbb
JOIN matches m ON bbb.Match_Id = m.Match_Id
JOIN season s ON m.Season_Id = s.Season_Id
JOIN player p ON bbb.Bowler = p.Player_Id
LEFT JOIN wicket_taken wt ON bbb.Match_Id = wt.Match_Id 
                    AND bbb.Over_Id = wt.Over_Id 
                    AND bbb.Ball_Id = wt.Ball_Id
WHERE s.Season_Year >= (SELECT MAX(Season_Year) - 3 FROM season)
GROUP BY p.Player_Name
HAVING COUNT(*) >= 30 -- min overs
ORDER BY Wickets DESC, Wicket_Per_Ball DESC
LIMIT 10;


-- Q3) What are some of the parameters that should be focused on while selecting the players?

SELECT 
    p.Player_Name,
    COUNT(*) AS Balls_Faced,
    SUM(bbb.Runs_Scored) AS Total_Runs,
    ROUND(SUM(bbb.Runs_Scored) * 1.0 / COUNT(*), 2) AS Strike_Rate,
    ROUND(SUM(bbb.Runs_Scored) * 1.0 / COUNT(DISTINCT m.Match_Id), 2) AS Runs_Per_Match
FROM ball_by_ball bbb
JOIN matches m ON bbb.Match_Id = m.Match_Id
JOIN season s ON m.Season_Id = s.Season_Id
JOIN player p ON bbb.Striker = p.Player_Id
WHERE s.Season_Year >= (SELECT MAX(Season_Year) - 2 FROM season)
GROUP BY p.Player_Name
HAVING COUNT(*) >= 30 -- At least 30 balls faced
ORDER BY Strike_Rate DESC, Total_Runs DESC
LIMIT 20;


-- Q4) Which players offer versatility in their skills and can contribute effectively with both bat and ball? (can you visualize the data for the same)

WITH batting AS (
    SELECT 
        p.Player_Id,
        p.Player_Name,
        COUNT(*) AS Balls_Faced,
        SUM(bbb.Runs_Scored) AS Total_Runs,
        ROUND(SUM(bbb.Runs_Scored) * 100.0 / COUNT(*), 2) AS Strike_Rate
    FROM ball_by_ball bbb
    JOIN matches m ON bbb.Match_Id = m.Match_Id
    JOIN season s ON m.Season_Id = s.Season_Id
    JOIN player p ON bbb.Striker = p.Player_Id
    WHERE s.Season_Year >= (SELECT MAX(Season_Year) - 2 FROM season)
    GROUP BY p.Player_Id, p.Player_Name
    HAVING COUNT(*) >= 30
),
bowling AS (
    SELECT 
        p.Player_Id,
        COUNT(*) AS Balls_Bowled,
        COUNT(wt.Player_out) AS Wickets,
        ROUND(COUNT(wt.Player_out) * 1.0 / COUNT(*), 2) AS Wickets_Per_Ball
    FROM ball_by_ball bbb
    JOIN matches m ON bbb.Match_Id = m.Match_Id
    JOIN season s ON m.Season_Id = s.Season_Id
    JOIN player p ON bbb.Bowler = p.Player_Id
    LEFT JOIN wicket_taken wt ON bbb.Match_Id = wt.Match_Id 
                        AND bbb.Over_Id = wt.Over_Id 
                        AND bbb.Ball_Id = wt.Ball_Id
    WHERE s.Season_Year >= (SELECT MAX(Season_Year) - 2 FROM season)
    GROUP BY p.Player_Id
    HAVING COUNT(*) >= 30
)

SELECT 
    b.Player_Name,
    b.Total_Runs,
    b.Strike_Rate,
    bw.Wickets,
    bw.Wickets_Per_Ball
FROM batting b
JOIN bowling bw ON b.Player_Id = bw.Player_Id
ORDER BY b.Total_Runs DESC, bw.Wickets DESC;


-- Q5) Are there players whose presence positively influences the morale and performance of the team? (justify your answer using visualization)

WITH player_wins AS (
    SELECT 
        pm.Player_Id,
        p.Player_Name,
        COUNT(*) AS Matches_Played,
        SUM(CASE WHEN m.Match_winner = pm.Team_Id THEN 1 ELSE 0 END) AS Matches_Won
    FROM player_match pm
    JOIN matches m ON pm.Match_Id = m.Match_Id
    JOIN player p ON pm.Player_Id = p.Player_Id
    GROUP BY pm.Player_Id, p.Player_Name
    HAVING COUNT(*) >= 10 -- only players with decent match count
),
win_rate AS (
    SELECT 
        Player_Name,
        Matches_Played,
        Matches_Won,
        ROUND(Matches_Won * 100.0 / Matches_Played, 2) AS Win_Percentage
    FROM player_wins
)
SELECT 
    *
FROM win_rate
ORDER BY Win_Percentage DESC
LIMIT 15;


-- Q6) What would you suggest to RCB before going to the mega auction?

WITH batting_stats AS (
    SELECT 
        p.Player_Id,
        p.Player_Name,
        COUNT(*) AS Balls_Faced,
        SUM(bbb.Runs_Scored) AS Total_Runs,
        ROUND(SUM(bbb.Runs_Scored) * 100.0 / COUNT(*), 2) AS Strike_Rate
    FROM ball_by_ball bbb
    JOIN matches m ON bbb.Match_Id = m.Match_Id
    JOIN season s ON m.Season_Id = s.Season_Id
    JOIN player p ON bbb.Striker = p.Player_Id
    WHERE s.Season_Year >= (SELECT MAX(Season_Year) - 2 FROM season)
    GROUP BY p.Player_Id, p.Player_Name
    HAVING COUNT(*) >= 30
),
bowling_stats AS (
    SELECT 
        p.Player_Id,
        COUNT(*) AS Balls_Bowled,
        COUNT(wt.Player_out) AS Total_Wickets,
        ROUND(COUNT(wt.Player_out) * 1.0 / COUNT(*), 2) AS Wicket_Per_Ball
    FROM ball_by_ball bbb
    JOIN matches m ON bbb.Match_Id = m.Match_Id
    JOIN season s ON m.Season_Id = s.Season_Id
    JOIN player p ON bbb.Bowler = p.Player_Id
    LEFT JOIN wicket_taken wt ON bbb.Match_Id = wt.Match_Id 
                        AND bbb.Over_Id = wt.Over_Id 
                        AND bbb.Ball_Id = wt.Ball_Id
    WHERE s.Season_Year >= (SELECT MAX(Season_Year) - 2 FROM season)
    GROUP BY p.Player_Id
    HAVING COUNT(*) >= 30
),
combined AS (
    SELECT 
        b.Player_Name,
        b.Total_Runs,
        b.Strike_Rate,
        bw.Total_Wickets,
        bw.Wicket_Per_Ball
    FROM batting_stats b
    JOIN bowling_stats bw ON b.Player_Id = bw.Player_Id
)

SELECT 
    *
FROM combined
ORDER BY Strike_Rate DESC, Total_Wickets DESC;


-- Q7) What do you think could be the factors contributing to the high-scoring matches and the impact on viewership and team strategies

SELECT 
    v.Venue_Name,
    ROUND(AVG(bbb.Runs_Scored), 2) AS Avg_Runs_Per_Ball,
    ROUND(SUM(bbb.Runs_Scored) * 1.0 / COUNT(DISTINCT m.Match_Id), 2) AS Avg_Total_Per_Match
FROM ball_by_ball bbb
JOIN matches m ON bbb.Match_Id = m.Match_Id
JOIN venue v ON m.Venue_Id = v.Venue_Id
GROUP BY v.Venue_Name
ORDER BY Avg_Total_Per_Match DESC
;


-- Q8) Analyze the impact of home-ground advantage on team performance and identify strategies to maximize this advantage for RCB.

WITH team_matches AS (
    SELECT 
        m.Match_Id,
        m.Match_winner,
        m.Team_1,
        m.Team_2,
        m.Venue_Id,
        t.Team_Name AS RCB_Team,
        v.Venue_Name,
        CASE 
            WHEN t.Team_Name = 'Royal Challengers Bangalore' 
                 AND (m.Team_1 = t.Team_Id OR m.Team_2 = t.Team_Id)
            THEN
                CASE 
                    WHEN v.Venue_Name LIKE '%Chinnaswamy%' THEN 'Home'
                    ELSE 'Away'
                END
        END AS Match_Type
    FROM matches m
    JOIN team t ON t.Team_Name = 'Royal Challengers Bangalore'
    JOIN venue v ON v.Venue_Id = m.Venue_Id
)
SELECT 
    Match_Type,
    COUNT(*) AS Matches_Played,
    SUM(CASE WHEN Match_winner = (SELECT Team_Id FROM team WHERE Team_Name = 'Royal Challengers Bangalore') THEN 1 ELSE 0 END) AS Matches_Won,
    ROUND(SUM(CASE WHEN Match_winner = (SELECT Team_Id FROM team WHERE Team_Name = 'Royal Challengers Bangalore') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Win_Percentage
FROM team_matches
WHERE Match_Type IS NOT NULL
GROUP BY Match_Type;


-- Q9) Come up with a visual and analytical analysis of the RCB's past season's performance and potential reasons for them not winning a trophy.

SELECT 
    s.Season_Year,
    COUNT(m.Match_Id) AS Matches_Played,
    SUM(CASE WHEN m.Match_winner = t.Team_Id THEN 1 ELSE 0 END) AS Matches_Won,
    ROUND(SUM(CASE WHEN m.Match_winner = t.Team_Id THEN 1 ELSE 0 END) * 100.0 / COUNT(m.Match_Id), 2) AS Win_Percentage
FROM matches m
JOIN season s ON m.Season_Id = s.Season_Id
JOIN team t ON t.Team_Name = 'Royal Challengers Bangalore'
WHERE m.Team_1 = t.Team_Id OR m.Team_2 = t.Team_Id
GROUP BY s.Season_Year
ORDER BY s.Season_Year;


-- Q10) How would you approach this problem, if the objective and subjective questions weren't given?

SELECT 
    s.Season_Year,
    COUNT(m.Match_Id) AS Matches_Played,
    SUM(CASE WHEN m.Match_winner = t.Team_Id THEN 1 ELSE 0 END) AS Matches_Won,
    ROUND(SUM(CASE WHEN m.Match_winner = t.Team_Id THEN 1 ELSE 0 END) * 100.0 / COUNT(m.Match_Id), 2) AS Win_Percentage
FROM matches m
JOIN season s ON m.Season_Id = s.Season_Id
JOIN team t ON t.Team_Name = 'Royal Challengers Bangalore'
WHERE m.Team_1 = t.Team_Id OR m.Team_2 = t.Team_Id
GROUP BY s.Season_Year
ORDER BY s.Season_Year;


-- Q11) In the "Match" table, some entries in the "Opponent_Team" column are incorrectly spelled as "Delhi_Capitals" instead of "Delhi_Daredevils". 
-- Write an SQL query to replace all occurrences of "Delhi_Capitals" with "Delhi_Daredevils".


UPDATE matches
SET 
    Team_1 = CASE WHEN Team_1 = 'Delhi_Capitals' THEN 'Delhi_Daredevils' ELSE Team_1 END,
    Team_2 = CASE WHEN Team_2 = 'Delhi_Capitals' THEN 'Delhi_Daredevils' ELSE Team_2 END
WHERE Team_1 = 'Delhi_Capitals' OR Team_2 = 'Delhi_Capitals';



