SELECT 
    fixture_id, 
    SUBSTR(fixture_date, 1, 10) AS dt_game,
    teams_home_id AS team_id,
    teams_away_id AS opponent_id,
    CASE WHEN teams_home_winner THEN 1 ELSE 0 END AS win,
    CASE WHEN teams_home_winner IS NULL THEN 1 ELSE 0 END AS draw,
    CASE WHEN teams_home_winner = 0 THEN 1 ELSE 0 END AS lose,
    goals_home AS goals_for,
    goals_away AS goals_against,
    1 AS is_home
FROM silver_fixtures

UNION ALL

SELECT
    fixture_id, 
    SUBSTR(fixture_date, 1, 10) AS dt_game,
    teams_away_id AS team_id,
    teams_home_id AS opponent_id,
    CASE WHEN teams_away_winner THEN 1 ELSE 0 END AS win,
    CASE WHEN teams_away_winner IS NULL THEN 1 ELSE 0 END AS draw,
    CASE WHEN teams_away_winner = 0 THEN 1 ELSE 0 END AS lose,
    goals_away AS goals_for,
    goals_home AS goals_against,
    0 AS is_home
FROM silver_fixtures