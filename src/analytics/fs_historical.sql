WITH tb_team AS(
SELECT 
    fixture_id,
    team_id,
    opponent_id,
    dt_game,
    COUNT(*) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS total_games_before,
    SUM(win) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS wins_before,
    SUM(draw) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS draws_before,
    SUM(lose) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS loses_before,
    SUM(goals_for) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS goals_for_before,
    SUM(goals_against) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS goals_against_before,
    SUM(CASE WHEN is_home THEN goals_for ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS home_goals_for_before,
    SUM(CASE WHEN is_home = 0 THEN goals_for ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS away_goals_for_before,
    SUM(CASE WHEN is_home THEN goals_against ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS home_goals_against_before,
    SUM(CASE WHEN is_home = 0 THEN goals_against ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS away_goals_against_before,
    SUM(CASE WHEN is_home THEN win ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS total_home_wins_before,
    SUM(CASE WHEN is_home = 0 THEN win ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS total_away_wins_before,
    SUM(CASE WHEN is_home THEN lose ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS total_home_loses_before,
    SUM(CASE WHEN is_home = 0 THEN lose ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS total_away_loses_before,
    SUM(CASE WHEN is_home THEN draw ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS total_home_draws_before,
    SUM(CASE WHEN is_home = 0 THEN draw ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS total_away_draws_before,
    SUM(CASE WHEN is_home THEN 1 ELSE 0 END) OVER (PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS home_games_before,
    SUM(CASE WHEN is_home = 0 THEN 1 ELSE 0 END) OVER (PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                UNBOUNDED PRECEDING AND 1 PRECEDING) AS away_games_before
FROM fs_union
)

SELECT 
    t1.fixture_id,
    t1.team_id,
    t1.opponent_id,
    t1.dt_game,
    COALESCE(t1.total_games_before, 0) AS total_games_before,
    COALESCE(t1.wins_before, 0) AS wins_before,
    COALESCE(t1.draws_before, 0) AS draws_before,
    COALESCE(t1.loses_before, 0) AS loses_before,
    COALESCE(t1.goals_for_before, 0) AS goals_for_before,
    COALESCE(t1.goals_against_before, 0) AS goals_against_before,
    COALESCE(t1.home_goals_for_before, 0) AS home_goals_for_before,
    COALESCE(t1.away_goals_for_before, 0) AS away_goals_for_before,
    COALESCE(t1.home_goals_against_before, 0) AS home_goals_against_before,
    COALESCE(t1.away_goals_against_before, 0) AS away_goals_against_before,
    COALESCE(t1.total_home_wins_before, 0) AS total_home_wins_before,
    COALESCE(t1.total_away_wins_before, 0) AS total_away_wins_before,
    COALESCE(t1.total_home_loses_before, 0) AS total_home_loses_before,
    COALESCE(t1.total_away_loses_before, 0) AS total_away_loses_before,
    COALESCE(t1.total_home_draws_before, 0) AS total_home_draws_before,
    COALESCE(t1.total_away_draws_before, 0) AS total_away_draws_before,
    COALESCE(t1.home_games_before, 0) AS home_games_before,
    COALESCE(t1.away_games_before, 0) AS away_games_before,
    CASE WHEN t1.total_games_before = 0 THEN 1 ELSE 0 END AS is_first_game,
    CASE WHEN COALESCE(t1.home_games_before, 0) = 0 THEN 1 ELSE 0 END AS not_played_home_before,
    CASE WHEN COALESCE(t1.away_games_before, 0) = 0 THEN 1 ELSE 0 END AS not_played_away_before,
    ROUND(1. * t1.total_home_wins_before / NULLIF(t1.home_games_before, 0), 4) AS team_home_win_rate,
    ROUND(1. * t1.total_away_wins_before / NULLIF(t1.away_games_before, 0), 4) AS team_away_win_rate,
    ROUND(1. * t1.total_home_wins_before / NULLIF(t1.wins_before, 0), 4) AS team_home_wins_share,
    ROUND(1. * t1.total_away_wins_before / NULLIF(t1.wins_before, 0), 4) AS team_away_wins_share,
    ROUND(1. * t1.total_home_loses_before / NULLIF(t1.loses_before, 0), 4) AS team_home_loses_share,
    ROUND(1. * t1.total_away_loses_before / NULLIF(t1.loses_before, 0), 4) AS team_away_loses_share,
    ROUND(1. * t1.total_home_draws_before / NULLIF(t1.draws_before, 0), 4) AS team_home_draws_share,
    ROUND(1. * t1.total_away_draws_before / NULLIF(t1.draws_before, 0), 4) AS team_away_draws_share,
    ROUND(1. * t1.goals_for_before / NULLIF(t1.total_games_before, 0), 4) AS team_avg_goals_for,
    ROUND(1. * t1.goals_against_before / NULLIF(t1.total_games_before, 0), 4) AS team_avg_goals_against,
    ROUND(1. * t1.home_goals_for_before / NULLIF(t1.goals_for_before, 0), 4) AS team_home_goals_for_rate,
    ROUND(1. * t1.away_goals_for_before / NULLIF(t1.goals_for_before, 0), 4) AS team_away_goals_for_rate,
    ROUND(1. * t1.home_goals_against_before / NULLIF(t1.goals_against_before, 0), 4) AS team_home_goals_against_rate,
    ROUND(1. * t1.away_goals_against_before / NULLIF(t1.goals_against_before, 0), 4) AS team_away_goals_against_rate,
    ROUND(1. * t1.wins_before / NULLIF(t1.total_games_before, 0), 4) AS team_win_rate,
    ROUND(1. * t1.draws_before / NULLIF(t1.total_games_before, 0), 4) AS team_draw_rate,
    ROUND(1. * t1.loses_before / NULLIF(t1.total_games_before, 0), 4) AS team_lose_rate,
    ROUND(1. * (t1.goals_for_before - t1.goals_against_before) / NULLIF(t1.total_games_before, 0), 4) as team_avg_goal_diff,
    COALESCE(t1.goals_for_before - t1.goals_against_before, 0) AS team_goals_diff_before, 

    -- Opponent
    COALESCE(t2.total_games_before, 0) AS op_total_games_before,
    COALESCE(t2.wins_before, 0) AS op_wins_before,
    COALESCE(t2.draws_before, 0) AS op_draws_before,
    COALESCE(t2.loses_before, 0) AS op_loses_before,
    COALESCE(t2.goals_for_before, 0) AS op_goals_for_before,
    COALESCE(t2.goals_against_before, 0) AS op_goals_against_before,
    COALESCE(t2.home_goals_for_before, 0) AS op_home_goals_for_before,
    COALESCE(t2.away_goals_for_before, 0) AS op_away_goals_for_before,
    COALESCE(t2.home_goals_against_before, 0) AS op_home_goals_against_before,
    COALESCE(t2.away_goals_against_before, 0) AS op_away_goals_against_before,
    COALESCE(t2.total_home_wins_before, 0) AS op_total_home_wins_before,
    COALESCE(t2.total_away_wins_before, 0) AS op_total_away_wins_before,
    COALESCE(t2.total_home_loses_before, 0) AS op_total_home_loses_before,
    COALESCE(t2.total_away_loses_before, 0) AS op_total_away_loses_before,
    COALESCE(t2.total_home_draws_before, 0) AS op_total_home_draws_before,
    COALESCE(t2.total_away_draws_before, 0) AS op_total_away_draws_before,
    COALESCE(t2.home_games_before, 0) AS op_home_games_before,
    COALESCE(t2.away_games_before, 0) AS op_away_games_before,
    CASE WHEN t2.total_games_before = 0 THEN 1 ELSE 0 END AS op_is_first_game,
    CASE WHEN COALESCE(t2.home_games_before, 0) = 0 THEN 1 ELSE 0 END AS op_not_played_home_before,
    CASE WHEN COALESCE(t2.away_games_before, 0) = 0 THEN 1 ELSE 0 END AS op_not_played_away_before,
    ROUND(1. * t2.total_home_wins_before / NULLIF(t2.home_games_before, 0), 4) AS op_home_win_rate,
    ROUND(1. * t2.total_away_wins_before / NULLIF(t2.away_games_before, 0), 4) AS op_away_win_rate,
    ROUND(1. * t2.total_home_wins_before / NULLIF(t2.wins_before, 0), 4) AS op_home_wins_share,
    ROUND(1. * t2.total_away_wins_before / NULLIF(t2.wins_before, 0), 4) AS op_away_wins_share,
    ROUND(1. * t2.total_home_loses_before / NULLIF(t2.loses_before, 0), 4) AS op_home_loses_share,
    ROUND(1. * t2.total_away_loses_before / NULLIF(t2.loses_before, 0), 4) AS op_away_loses_share,
    ROUND(1. * t2.total_home_draws_before / NULLIF(t2.draws_before, 0), 4) AS op_home_draws_share,
    ROUND(1. * t2.total_away_draws_before / NULLIF(t2.draws_before, 0), 4) AS op_away_draws_share,
    ROUND(1. * t2.goals_for_before / NULLIF(t2.total_games_before, 0), 4) AS op_avg_goals_for,
    ROUND(1. * t2.goals_against_before / NULLIF(t2.total_games_before, 0), 4) AS op_avg_goals_against,
    ROUND(1. * t2.home_goals_for_before / NULLIF(t2.goals_for_before, 0), 4) AS op_home_goals_for_rate,
    ROUND(1. * t2.away_goals_for_before / NULLIF(t2.goals_for_before, 0), 4) AS op_away_goals_for_rate,
    ROUND(1. * t2.home_goals_against_before / NULLIF(t2.goals_against_before, 0), 4) AS op_home_goals_against_rate,
    ROUND(1. * t2.away_goals_against_before / NULLIF(t2.goals_against_before, 0), 4) AS op_away_goals_against_rate,
    ROUND(1. * t2.wins_before / NULLIF(t2.total_games_before, 0), 4) AS op_win_rate,
    ROUND(1. * t2.draws_before / NULLIF(t2.total_games_before, 0), 4) AS op_draw_rate,
    ROUND(1. * t2.loses_before / NULLIF(t2.total_games_before, 0), 4) AS op_lose_rate,
    ROUND(1. * (t2.goals_for_before - t2.goals_against_before) / NULLIF(t2.total_games_before, 0), 4) as op_avg_goal_diff,
    COALESCE(t2.goals_for_before - t2.goals_against_before, 0) AS op_goals_diff_before

FROM tb_team t1
LEFT JOIN tb_team t2
ON t1.fixture_id = t2.fixture_id
AND t1.opponent_id = t2.team_id