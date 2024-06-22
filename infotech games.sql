use game;

select * from level;
select * from player;

---#1  Extract `P_ID`, `Dev_ID`, `PName`, and `Difficulty_level` of all players at Level 0.
SELECT 
    l.p_id, dev_id, p.pname, l.difficulty, l.G_Level
FROM
    levels l
        JOIN
    player p ON l.p_id = p.p_id
WHERE
    l.G_Level = 0;

-- Q2) Find Level1_code wise Avg_Kill_Count where lives_earned is 2 and atleast 3 stages are crossed
SELECT 
    p.l1_code, ROUND(AVG(l.kill_count), 2) AS Avg_kill_Count
FROM
    levels l
        JOIN
    player p ON l.p_id = p.p_id
WHERE
    l.lives_earned = 2
        AND l.stages_crossed >= 3
GROUP BY p.l1_code;

-- Q3) Find the total number of stages crossed at each diffuculty level
-- where for Level2 with players use zm_series devices. Arrange the result
-- in decsreasing order of total number of stages crossed.
SELECT 
    SUM(stages_crossed) AS Sum_of_stages_crossed, difficulty
FROM
    levels
WHERE
    g_level = 2 AND dev_id LIKE 'zm%'
GROUP BY difficulty;


-- Q4) Extract P_ID and the total number of unique dates for those players 
-- who have played games on multiple days.
SELECT 
    p_id, COUNT(DISTINCT DATE(TimeStamp)) AS Unique_dates
FROM
    levels
GROUP BY p_id
HAVING COUNT(DISTINCT DATE(TimeStamp)) > 1;

-- Q5) Find P_ID and level wise sum of kill_counts where kill_count
-- is greater than avg kill count for the Medium difficulty.
SELECT 
    p_id, g_level, SUM(kill_count) AS Total_Kills
FROM
    levels
WHERE
    difficulty = 'medium'
GROUP BY p_id , g_level
HAVING SUM(kill_count) > (SELECT 
        AVG(kill_count)
    FROM
        levels
    WHERE
        difficulty = 'medium');

-- Q6)  Find Level and its corresponding Level code wise sum of lives earned 
-- excluding level 0. Arrange in asecending order of level.
select 
    l.g_level,
    p.l1_code,
    p.l2_code,
    SUM(l.lives_earned) as Total_Life_Earned
from
    levels l
        join
    player p on l.p_id = p.p_id
where
    l.g_level != 0
group by l.g_level , p.l1_code , p.l2_code
order by l.g_level;

-- Q7) Find Top 3 score based on each dev_id and Rank them in increasing order
-- using Row_Number. Display difficulty as well. 
select dev_id, score, difficulty
from (
    select dev_id, score, difficulty,
           row_number() over (partition by dev_id order by score asc) as ranks
    from levels
) as ranked_scores
where ranks <= 3;

-- Q8) Find first_login datetime for each device id
select 
    dev_id, MIN(time(TimeStamp)) as first_login
from
    levels
group by dev_id;


-- Q9) Find Top 5 score based on each difficulty level and Rank them in 
-- increasing order using Rank. Display dev_id as well.
select  dev_id, score, difficulty, ranks
from (
    select dev_id, score, difficulty,
           rank() over (partition by  difficulty order by  score asc) as ranks
    from levels
) as ranked_scores
where ranks <= 5;


 -- Q10) Find the device ID that is first logged in(based on start_datetime) 
-- for each player(p_id). Output should contain player id, device id and 
-- first login datetime.
select p_id, dev_id, min(TimeStamp) as first_login
from levels
group by p_id, dev_id;


-- Q11) For each player and date, how many kill_count played so far by the player. That is, the total number of games played 
-- by the player until that date.
-- a) window function
-- b) without window function
SELECT 
    p_id,
    COUNT(p_id) AS total_number_of_game_played,
    TimeStamp,
    SUM(kill_count) AS sum_of_kill_count
FROM
    levels
GROUP BY p_id , TimeStamp;

-- Q12) Find the cumulative sum of an stages crossed over a start_datetime 
-- for each player id but exclude the most recent start_datetime
select p_id, 
       SUM(stages_crossed) as sum_of_stages_crossed,
       MAX(TimeStamp) as old_date
from (
    select p_id, 
           stages_crossed, 
           TimeStamp,
           row_number() over (partition by p_id order by TimeStamp desc) as rn
    from levels
) as ranked
where rn > 1
group by p_id;
select dev_id, p_id, total_scores
from (
    select dev_id, p_id, SUM(score) AS total_scores,
           row_number() over (partition by dev_id order by SUM(score) desc) as ranks
    from levels
    group by dev_id, p_id
) as ranked_scores
where ranks <= 3;
select l.p_id, p.pname, sum(l.score) as total_score 
FROM
    levels l
        JOIN
    player p ON l.p_id = p.p_id
group by p_id
having sum(l.score) > 0.5 * (select avg(Score) from Levels where p_id = l.p_id);


-- Q15) Create a stored procedure to find top n headshots_count based on each dev_id and Rank them in increasing order
-- using Row_Number. Display difficulty as well.
select dev_id, sum(headshots_count), difficulty
from (
    select dev_id, sum(headshots_count), difficulty,
           row_number() over (partition by dev_id order by sum(headshots_count) asc) as ranks
    from levels
) as ranked_headshots_count;
