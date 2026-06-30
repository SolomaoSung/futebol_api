WITH tb_team AS(
SELECT 
    fixture_id,
    team_id,
    opponent_id,
    COUNT(*) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS total_games_last5,
    SUM(win) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS wins_last5,
    SUM(draw) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS draws_last5,
    SUM(lose) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS loses_last5,
    SUM(goals_for) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS goals_for_last5,
    SUM(goals_against) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS goals_against_last5,
    SUM(CASE WHEN is_home THEN goals_for ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS home_goals_for_last5,
    SUM(CASE WHEN is_home = 0 THEN goals_for ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS away_goals_for_last5,
    SUM(CASE WHEN is_home THEN goals_against ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS home_goals_against_last5,
    SUM(CASE WHEN is_home = 0 THEN goals_against ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS away_goals_against_last5,
    SUM(CASE WHEN is_home THEN win ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS total_home_wins_last5,
    SUM(CASE WHEN is_home = 0 THEN win ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS total_away_wins_last5,
    SUM(CASE WHEN is_home THEN lose ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS total_home_loses_last5,
    SUM(CASE WHEN is_home = 0 THEN lose ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS total_away_loses_last5,
    SUM(CASE WHEN is_home THEN draw ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS total_home_draws_last5,
    SUM(CASE WHEN is_home = 0 THEN draw ELSE 0 END) OVER(PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS total_away_draws_last5,
    SUM(CASE WHEN is_home THEN 1 ELSE 0 END) OVER (PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS home_games_last5,
    SUM(CASE WHEN is_home = 0 THEN 1 ELSE 0 END) OVER (PARTITION BY team_id ORDER BY dt_game, fixture_id ROWS BETWEEN
                5 PRECEDING AND 1 PRECEDING) AS away_games_last5
FROM fs_union
)

SELECT 
    t1.team_id,
    t1.fixture_id,
    t1.opponent_id,
    COALESCE(t1.total_games_last5, 0) AS team_total_games_last5,
    COALESCE(t1.wins_last5, 0) AS team_wins_last5,
    COALESCE(t1.draws_last5, 0) AS team_draws_last5,
    COALESCE(t1.loses_last5, 0) AS team_loses_last5,
    COALESCE(t1.goals_for_last5, 0) AS team_goals_for_last5,
    COALESCE(t1.goals_against_last5, 0) AS team_goals_against_last5,
    COALESCE(t1.home_goals_for_last5, 0) AS team_home_goals_for_last5,
    COALESCE(t1.away_goals_for_last5, 0) AS team_away_goals_for_last5,
    COALESCE(t1.home_goals_against_last5, 0) AS team_home_goals_against_last5,
    COALESCE(t1.away_goals_against_last5, 0) AS team_away_goals_against_last5,
    COALESCE(t1.total_home_wins_last5, 0) AS team_total_home_wins_last5,
    COALESCE(t1.total_away_wins_last5, 0) AS team_total_away_wins_last5,
    COALESCE(t1.total_home_loses_last5, 0) AS team_total_home_loses_last5,
    COALESCE(t1.total_away_loses_last5, 0) AS team_total_away_loses_last5,
    COALESCE(t1.total_home_draws_last5, 0) AS team_total_home_draws_last5,
    COALESCE(t1.total_away_draws_last5, 0) AS team_total_away_draws_last5,
    COALESCE(t1.home_games_last5, 0) AS home_games_last5,
    COALESCE(t1.away_games_last5, 0) AS away_games_last5,
    CASE WHEN t1.total_games_last5 = 0 THEN 1 ELSE 0 END AS is_first_game,
    CASE WHEN COALESCE(t1.home_games_last5, 0) = 0 THEN 1 ELSE 0 END AS not_played_home_last5,
    CASE WHEN COALESCE(t1.away_games_last5, 0) = 0 THEN 1 ELSE 0 END AS not_played_away_last5,
    ROUND(1. * t1.total_home_wins_last5 / NULLIF(t1.home_games_last5, 0), 4) AS team_home_win_rate_last5,
    ROUND(1. * t1.total_away_wins_last5 / NULLIF(t1.away_games_last5, 0), 4) AS team_away_win_rate_last5,
    ROUND(1. * t1.total_home_wins_last5 / NULLIF(t1.wins_last5, 0), 4) AS team_home_wins_share_last5,
    ROUND(1. * t1.total_away_wins_last5 / NULLIF(t1.wins_last5, 0), 4) AS team_away_wins_share_last5,
    ROUND(1. * t1.total_home_loses_last5 / NULLIF(t1.loses_last5, 0), 4) AS team_home_loses_share_last5,
    ROUND(1. * t1.total_away_loses_last5 / NULLIF(t1.loses_last5, 0), 4) AS team_away_loses_share_last5,
    ROUND(1. * t1.total_home_draws_last5 / NULLIF(t1.draws_last5, 0), 4) AS team_home_draws_share_last5,
    ROUND(1. * t1.total_away_draws_last5 / NULLIF(t1.draws_last5, 0), 4) AS team_away_draws_share_last5,
    ROUND(1. * t1.goals_for_last5 / NULLIF(t1.total_games_last5, 0), 4) AS team_avg_goals_for_last5,
    ROUND(1. * t1.goals_against_last5 / NULLIF(t1.total_games_last5, 0), 4) AS team_avg_goals_against_last5,
    ROUND(1. * t1.home_goals_for_last5 / NULLIF(t1.goals_for_last5, 0), 4) AS team_home_goals_for_rate_last5,
    ROUND(1. * t1.away_goals_for_last5 / NULLIF(t1.goals_for_last5, 0), 4) AS team_away_goals_for_rate_last5,
    ROUND(1. * t1.home_goals_against_last5 / NULLIF(t1.goals_against_last5, 0), 4) AS team_home_goals_against_rate_last5,
    ROUND(1. * t1.away_goals_against_last5 / NULLIF(t1.goals_against_last5, 0), 4) AS team_away_goals_against_rate_last5,
    ROUND(1. * t1.wins_last5 / NULLIF(t1.total_games_last5, 0), 4) AS team_win_rate_last5,
    ROUND(1. * t1.draws_last5 / NULLIF(t1.total_games_last5, 0), 4) AS team_draw_rate_last5,
    ROUND(1. * t1.loses_last5 / NULLIF(t1.total_games_last5, 0), 4) AS team_lose_rate_last5,
    ROUND(1. * (t1.goals_for_last5 - t1.goals_against_last5) / NULLIF(t1.total_games_last5, 0), 4) as team_avg_goal_diff_last5,
    t1.goals_for_last5 - t1.goals_against_last5 AS team_goals_diff_last5,

    -- Opponent
    COALESCE(t2.total_games_last5, 0) AS op_total_games_last5,
    COALESCE(t2.wins_last5, 0) AS op_wins_last5,
    COALESCE(t2.draws_last5, 0) AS op_draws_last5,
    COALESCE(t2.loses_last5, 0) AS op_loses_last5,
    COALESCE(t2.goals_for_last5, 0) AS op_goals_for_last5,
    COALESCE(t2.goals_against_last5, 0) AS op_goals_against_last5,
    COALESCE(t2.home_goals_for_last5, 0) AS op_home_goals_for_last5,
    COALESCE(t2.away_goals_for_last5, 0) AS op_away_goals_for_last5,
    COALESCE(t2.home_goals_against_last5, 0) AS op_home_goals_against_last5,
    COALESCE(t2.away_goals_against_last5, 0) AS op_away_goals_against_last5,
    COALESCE(t2.total_home_wins_last5, 0) AS op_total_home_wins_last5,
    COALESCE(t2.total_away_wins_last5, 0) AS op_total_away_wins_last5,
    COALESCE(t2.total_home_loses_last5, 0) AS op_total_home_loses_last5,
    COALESCE(t2.total_away_loses_last5, 0) AS op_total_away_loses_last5,
    COALESCE(t2.total_home_draws_last5, 0) AS op_total_home_draws_last5,
    COALESCE(t2.total_away_draws_last5, 0) AS op_total_away_draws_last5,
    COALESCE(t2.home_games_last5, 0) AS op_home_games_last5,
    COALESCE(t2.away_games_last5, 0) AS op_away_games_last5,
    CASE WHEN t1.total_games_last5 = 0 THEN 1 ELSE 0 END AS op_is_first_game,
    CASE WHEN COALESCE(t2.home_games_last5, 0) = 0 THEN 1 ELSE 0 END AS op_not_played_home_last5,
    CASE WHEN COALESCE(t2.away_games_last5, 0) = 0 THEN 1 ELSE 0 END AS op_not_played_away_last5,
    ROUND(1. * t2.total_home_wins_last5 / NULLIF(t2.home_games_last5, 0), 4) AS op_home_win_rate_last5,
    ROUND(1. * t2.total_away_wins_last5 / NULLIF(t2.away_games_last5, 0), 4) AS op_away_win_rate_last5,
    ROUND(1. * t2.total_home_wins_last5 / NULLIF(t2.wins_last5, 0), 4) AS op_home_wins_share_last5,
    ROUND(1. * t2.total_away_wins_last5 / NULLIF(t2.wins_last5, 0), 4) AS op_away_wins_share_last5,
    ROUND(1. * t2.total_home_loses_last5 / NULLIF(t2.loses_last5, 0), 4) AS op_home_loses_share_last5,
    ROUND(1. * t2.total_away_loses_last5 / NULLIF(t2.loses_last5, 0), 4) AS op_away_loses_share_last5,
    ROUND(1. * t2.total_home_draws_last5 / NULLIF(t2.draws_last5, 0), 4) AS op_home_draws_share_last5,
    ROUND(1. * t2.total_away_draws_last5 / NULLIF(t2.draws_last5, 0), 4) AS op_away_draws_share_last5,
    ROUND(1. * t2.goals_for_last5 / NULLIF(t2.total_games_last5, 0), 4) AS op_avg_goals_for_last5,
    ROUND(1. * t2.goals_against_last5 / NULLIF(t2.total_games_last5, 0), 4) AS op_avg_goals_against_last5,
    ROUND(1. * t2.home_goals_for_last5 / NULLIF(t2.goals_for_last5, 0), 4) AS op_home_goals_for_rate_last5,
    ROUND(1. * t2.away_goals_for_last5 / NULLIF(t2.goals_for_last5, 0), 4) AS op_away_goals_for_rate_last5,
    ROUND(1. * t2.home_goals_against_last5 / NULLIF(t2.goals_against_last5, 0), 4) AS op_home_goals_against_rate_last5,
    ROUND(1. * t2.away_goals_against_last5 / NULLIF(t2.goals_against_last5, 0), 4) AS op_away_goals_against_rate_last5,
    ROUND(1. * t2.wins_last5 / NULLIF(t2.total_games_last5, 0), 4) AS op_win_rate_last5,
    ROUND(1. * t2.draws_last5 / NULLIF(t2.total_games_last5, 0), 4) AS op_draw_rate_last5,
    ROUND(1. * t2.loses_last5 / NULLIF(t2.total_games_last5, 0), 4) AS op_lose_rate_last5,
    ROUND(1. * (t2.goals_for_last5 - t2.goals_against_last5) / NULLIF(t2.total_games_last5, 0), 4) as op_avg_goal_diff_last5,
    t2.goals_for_last5 - t2.goals_against_last5 AS op_goals_diff_last5

FROM tb_team t1
LEFT JOIN tb_team t2
ON t1.fixture_id = t2.fixture_id
AND t1.opponent_id = t2.team_id