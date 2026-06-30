-- Blocking Sessions Diagnostic Query
-- Purpose: identify blocking chains.

SELECT
    -- The blocked session is waiting for the blocking session.
    blocked.session_id AS blocked_session_id,
    blocked.blocking_session_id,
    -- Wait details explain what the blocked query is waiting on.
    blocked.wait_type,
    blocked.wait_time,
    blocked.wait_resource,
    blocked.status,
    blocked.command,
    blocked_sql.text AS blocked_query,
    blocker_sql.text AS blocker_query
FROM sys.dm_exec_requests AS blocked
-- Query text for the session that is waiting.
OUTER APPLY sys.dm_exec_sql_text(blocked.sql_handle) AS blocked_sql
LEFT JOIN sys.dm_exec_requests AS blocker
    ON blocked.blocking_session_id = blocker.session_id
-- Query text for the session causing the block.
OUTER APPLY sys.dm_exec_sql_text(blocker.sql_handle) AS blocker_sql
WHERE blocked.blocking_session_id <> 0;
