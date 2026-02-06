WITH calendar AS (
   SELECT '2022-01-01'::DATE + (n || 'day')::INTERVAL AS date_from_calendar
   FROM GENERATE_SERIES(0, 150) n
),
daily_active_users AS (
   SELECT
       DATE_TRUNC('day', u.entry_at) AS ymd_from_entry_at,
       COUNT(DISTINCT u.user_id) AS dau
   FROM userentry u
   WHERE EXTRACT(YEAR FROM u.entry_at) = 2022
   GROUP BY ymd_from_entry_at
)
SELECT
   c.date_from_calendar,
   COALESCE(d.dau, 0) AS daily_active_users_cnt,
   MAX(COALESCE(d.dau, 0)) OVER (ORDER BY c.date_from_calendar) AS max_dau_cnt,
   COALESCE(d.dau, 0) - MAX(COALESCE(d.dau, 0)) OVER (ORDER BY c.date_from_calendar) AS diff_dau
FROM calendar c
LEFT JOIN daily_active_users d
   ON c.date_from_calendar = d.ymd_from_entry_at
ORDER BY c.date_from_calendar