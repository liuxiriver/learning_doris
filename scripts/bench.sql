SET enable_profile = true;
SET profile_level = 2;

EXPLAIN SELECT * FROM t;

SELECT count(*) AS num_rows
FROM t
WHERE k1 > 0;

CREATE TABLE IF NOT EXISTS t2 AS
SELECT k1, v1 FROM t;

SELECT /*+ SET_VAR(parallel_fragment_exec_instance_num=1) */
       t.k1, t.v1
FROM t
JOIN t2 USING (k1);

EXPLAIN SELECT k1, count(*) AS c
FROM t
GROUP BY k1;
