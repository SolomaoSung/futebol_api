SELECT 
    team_id,
    count(*) AS total_injuries,
    SUM(CASE WHEN player_type = "Missing Fixture" THEN 1 ELSE 0 END) AS missing_fixture,
    SUM(CASE WHEN player_type = "Questionable" THEN 1 ELSE 0 END) AS questionable, 
    fixture_id
FROM silver_injuries 
GROUP BY team_id, fixture_id