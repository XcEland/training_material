-- DMV Index Contention Example
-- Use this when inserts, updates, deletes, or reads appear to wait on indexes.
-- DMV used:
--   sys.dm_db_index_operational_stats: low-level index activity and waits

SELECT TOP 20
    -- object_name is the table name.
    OBJECT_NAME(ios.object_id, ios.database_id) AS table_name,
    -- index_name is the index being used.
    i.name AS index_name,
    -- leaf_insert_count shows insert activity at the index leaf level.
    ios.leaf_insert_count,
    -- leaf_update_count shows update activity at the index leaf level.
    ios.leaf_update_count,
    -- row_lock_wait_count shows how often row locks had to wait.
    ios.row_lock_wait_count,
    -- row_lock_wait_in_ms shows total row lock wait time.
    ios.row_lock_wait_in_ms,
    -- page_lock_wait_count shows how often page locks had to wait.
    ios.page_lock_wait_count,
    -- page_lock_wait_in_ms shows total page lock wait time.
    ios.page_lock_wait_in_ms
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS ios
JOIN sys.indexes AS i
    ON ios.object_id = i.object_id
   AND ios.index_id = i.index_id
WHERE OBJECT_NAME(ios.object_id, ios.database_id) IS NOT NULL
ORDER BY
    ios.row_lock_wait_in_ms + ios.page_lock_wait_in_ms DESC;

-- Beginner interpretation:
-- High lock wait counts can mean queries are competing for the same table or index.
-- High insert or update counts show indexes that receive frequent write activity.
-- Use this after choosing the database you want to investigate.
