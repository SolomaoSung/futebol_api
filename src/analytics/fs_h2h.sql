WITH tb_team_op_hist AS(
SELECT *,
    COUNT(*) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS games_vs_op_before,
    SUM(win) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS wins_vs_op_before,
    SUM(draw) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS draws_vs_op_before,
    SUM(lose) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS loses_vs_op_before,
    SUM(goals_for) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS goals_for_vs_op_before,
    SUM(goals_against) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS goals_against_vs_op_before,
    SUM(CASE WHEN is_home THEN win ELSE 0 END) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS home_wins_vs_op_before,
    SUM(CASE WHEN is_home THEN draw ELSE 0 END) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS home_draws_vs_op_before,
    SUM(CASE WHEN is_home THEN lose ELSE 0 END) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS home_loses_vs_op_before,
    SUM(CASE WHEN is_home = 0 THEN win ELSE 0 END) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS away_wins_vs_op_before,
    SUM(CASE WHEN is_home = 0 THEN draw ELSE 0 END) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS away_draws_vs_op_before,
    SUM(CASE WHEN is_home = 0 THEN lose ELSE 0 END) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS away_loses_vs_op_before,
    SUM(CASE WHEN is_home THEN 1 ELSE 0 END) OVER (PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS home_games_vs_op_before,
    SUM(CASE WHEN is_home = 0 THEN 1 ELSE 0 END) OVER (PARTITION BY team_id, opponent_id ORDER BY dt_game ROWS BETWEEN
        UNBOUNDED PRECEDING AND 1 PRECEDING) AS away_games_vs_op_before,
    LAG(win) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game) AS last_win_vs_op,
    LAG(draw) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game) AS last_draw_vs_op,
    LAG(lose) OVER(PARTITION BY team_id, opponent_id ORDER BY dt_game) AS last_lose_vs_op

FROM fs_union
)
SELECT 
    *,
    CASE WHEN games_vs_op_before = 0 THEN 1 ELSE 0 END AS is_first_game_against_op,
    CASE WHEN COALESCE(home_games_vs_op_before, 0) = 0 THEN 1 ELSE 0 END AS never_played_home_vs_op,
    CASE WHEN COALESCE(away_games_vs_op_before, 0) = 0 THEN 1 ELSE 0 END AS never_played_away_vs_op,
    ROUND(1. * wins_vs_op_before / NULLIF(games_vs_op_before, 0), 4) AS team_win_rate_vs_op,
    ROUND(1. * loses_vs_op_before / NULLIF(games_vs_op_before, 0), 4) AS team_lose_rate_vs_op,
    ROUND(1. * draws_vs_op_before / NULLIF(games_vs_op_before, 0), 4) AS team_draw_rate_vs_op,
    ROUND(1.0 * home_wins_vs_op_before / NULLIF(home_wins_vs_op_before + home_draws_vs_op_before + home_loses_vs_op_before, 0), 4) AS home_win_rate_vs_op,
    ROUND(1.0 * away_wins_vs_op_before / NULLIF(away_wins_vs_op_before + away_draws_vs_op_before + away_loses_vs_op_before, 0), 4) AS away_win_rate_vs_op,
    ROUND(1.0 * (goals_for_vs_op_before - goals_against_vs_op_before) / NULLIF(games_vs_op_before, 0), 4) AS avg_goal_diff_vs_op
FROM tb_team_op_hist