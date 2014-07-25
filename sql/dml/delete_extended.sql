-- complex datatype handling
CREATE TABLE tst_one_array (
    a INTEGER PRIMARY KEY,
    b INTEGER[]
    );
CREATE TABLE tst_arrays (
    a INTEGER[] PRIMARY KEY,
    b TEXT[],
    c FLOAT[]
    );

CREATE TYPE tst_enum_t AS ENUM ('a', 'b', 'c');
CREATE TABLE tst_one_enum (
    a INTEGER PRIMARY KEY,
    b tst_enum_t
    );
CREATE TABLE tst_enums (
    a tst_enum_t PRIMARY KEY,
    b tst_enum_t[]
    );

CREATE TYPE tst_comp_basic_t AS (a FLOAT, b TEXT, c INTEGER);
CREATE TYPE tst_comp_enum_t AS (a FLOAT, b tst_enum_t, c INTEGER);
CREATE TYPE tst_comp_enum_array_t AS (a FLOAT, b tst_enum_t[], c INTEGER);
CREATE TABLE tst_one_comp (
    a INTEGER PRIMARY KEY,
    b tst_comp_basic_t
    );
CREATE TABLE tst_comps (
    a tst_comp_basic_t PRIMARY KEY,
    b tst_comp_basic_t[]
    );
CREATE TABLE tst_comp_enum (
    a INTEGER PRIMARY KEY,
    b tst_comp_enum_t
    );
CREATE TABLE tst_comp_enum_array (
    a tst_comp_enum_t PRIMARY KEY,
    b tst_comp_enum_t[]
    );
CREATE TABLE tst_comp_one_enum_array (
    a INTEGER PRIMARY KEY,
    b tst_comp_enum_array_t
    );
CREATE TABLE tst_comp_enum_what (
    a tst_comp_enum_array_t PRIMARY KEY,
    b tst_comp_enum_array_t[]
    );

CREATE TYPE tst_comp_mix_t AS (
    a tst_comp_basic_t,
    b tst_comp_basic_t[],
    c tst_enum_t,
    d tst_enum_t[]
    );
CREATE TABLE tst_comp_mix_array (
    a tst_comp_mix_t PRIMARY KEY,
    b tst_comp_mix_t[]
    );

SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;

-- test_tbl_one_array_col
INSERT INTO tst_one_array (a, b) VALUES
    (1, '{1, 2, 3}'),
    (2, '{2, 3, 1}'),
    (3, '{3, 2, 1}');

-- test_tbl_arrays
INSERT INTO tst_arrays (a, b, c) VALUES
    ('{1, 2, 3}', '{"a", "b", "c"}', '{1.1, 2.2, 3.3}'),
    ('{2, 3, 1}', '{"b", "c", "a"}', '{2.2, 3.3, 1.1}'),
    ('{3, 1, 2}', '{"c", "a", "b"}', '{3.3, 1.1, 2.2}');

-- test_tbl_single_enum
INSERT INTO tst_one_enum (a, b) VALUES
    (1, 'a'),
    (2, 'b'),
    (3, 'c');

-- test_tbl_enums
INSERT INTO tst_enums (a, b) VALUES
    ('a', '{b, c}'),
    ('b', '{c, a}'),
    ('c', '{b, a}');

-- test_tbl_single_composites
INSERT INTO tst_one_comp (a, b) VALUES
    (1, ROW(1.0, 'a', 1)),
    (2, ROW(2.0, 'b', 2));

-- test_tbl_composites
INSERT INTO tst_comps (a, b) VALUES
    (ROW(1.0, 'a', 1), ARRAY[ROW(1, 'a', 1)::tst_comp_basic_t]),
    (ROW(2.0, 'b', 2), ARRAY[ROW(2, 'b', 2)::tst_comp_basic_t]),
    (ROW(3.0, 'c', 3), ARRAY[ROW(3, 'c', 3)::tst_comp_basic_t]);

-- test_tbl_composite_with_enums
INSERT INTO tst_comp_enum (a, b) VALUES
    (1, ROW(1.0, 'a', 1)),
    (2, ROW(2.0, 'b', 2)),
    (3, ROW(3.0, 'c', 3));

-- test_tbl_composite_with_enums_array
INSERT INTO tst_comp_enum_array (a, b) VALUES
    (ROW(1.0, 'a', 1), ARRAY[ROW(1, 'a', 1)::tst_comp_enum_t]),
    (ROW(2.0, 'b', 2), ARRAY[ROW(2, 'b', 2)::tst_comp_enum_t]),
    (ROW(3.0, 'c', 3), ARRAY[ROW(3, 'c', 3)::tst_comp_enum_t]);

-- test_tbl_composite_with_single_enums_array_in_composite
INSERT INTO tst_comp_one_enum_array (a, b) VALUES
    (1, ROW(1.0, '{a, b, c}', 1)),
    (2, ROW(2.0, '{a, b, c}', 2)),
    (3, ROW(3.0, '{a, b, c}', 3));

-- test_tbl_composite_with_enums_array_in_composite
INSERT INTO tst_comp_enum_what (a, b) VALUES
    (ROW(1.0, '{a, b, c}', 1), ARRAY[ROW(1, '{a, b, c}', 1)::tst_comp_enum_array_t]),
    (ROW(2.0, '{b, c, a}', 2), ARRAY[ROW(2, '{b, c, a}', 1)::tst_comp_enum_array_t]),
    (ROW(3.0, '{c, a, b}', 1), ARRAY[ROW(3, '{c, a, b}', 1)::tst_comp_enum_array_t]);

-- test_tbl_mixed_composites
INSERT INTO tst_comp_mix_array (a, b) VALUES
    (ROW(
        ROW(1,'a',1),
        ARRAY[ROW(1,'a',1)::tst_comp_basic_t, ROW(2,'b',2)::tst_comp_basic_t],
        'a',
        '{a,b,c}'),
    ARRAY[
        ROW(
            ROW(1,'a',1),
            ARRAY[
                ROW(1,'a',1)::tst_comp_basic_t,
                ROW(2,'b',2)::tst_comp_basic_t
                ],
            'a',
            '{a,b,c}'
            )::tst_comp_mix_t
        ]
    );

SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_one_array ORDER BY a;
SELECT a, b, c FROM tst_arrays ORDER BY a;
SELECT a, b FROM tst_one_enum ORDER BY a;
SELECT a, b FROM tst_enums ORDER BY a;
SELECT a, b FROM tst_one_comp ORDER BY a;
SELECT a, b FROM tst_comps ORDER BY a;
SELECT a, b FROM tst_comp_enum ORDER BY a;
SELECT a, b FROM tst_comp_enum_array ORDER BY a;
SELECT a, b FROM tst_comp_one_enum_array ORDER BY a;
SELECT a, b FROM tst_comp_enum_what ORDER BY a;
SELECT a, b FROM tst_comp_mix_array ORDER BY a;

-- test_tbl_one_array_col
DELETE FROM tst_one_array WHERE a = 1;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_one_array ORDER BY a;
DELETE FROM tst_one_array WHERE b = '{2, 3, 1}';
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_one_array ORDER BY a;
DELETE FROM tst_one_array WHERE 1 = ANY(b);
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_one_array ORDER BY a;

-- test_tbl_arrays
DELETE FROM tst_arrays WHERE a = '{1, 2, 3}';
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b, c FROM tst_arrays ORDER BY a;
DELETE FROM tst_arrays WHERE a[1] = 2;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b, c FROM tst_arrays ORDER BY a;
DELETE FROM tst_arrays WHERE b[1] = 'c';
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b, c FROM tst_arrays ORDER BY a;

-- test_tbl_single_enum
DELETE FROM tst_one_enum WHERE a = 1;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_one_enum ORDER BY a;
DELETE FROM tst_one_enum WHERE b = 'b';
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_one_enum ORDER BY a;

-- test_tbl_enums
DELETE FROM tst_enums WHERE a = 'a';
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_enums;
DELETE FROM tst_enums WHERE 'c' = ANY(b);
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_enums;
DELETE FROM tst_enums WHERE b[1] = 'b';
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_enums;

-- test_tbl_single_composites
DELETE FROM tst_one_comp WHERE a = 1;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b from tst_one_comp ORDER BY a;
DELETE FROM tst_one_comp WHERE (b).a = 2.0;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b from tst_one_comp ORDER BY a;

-- test_tbl_composites
DELETE FROM tst_comps WHERE (a).b = 'a';
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_comps ORDER BY a;
DELETE FROM tst_comps WHERE (b[1]).a = 2.0;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_comps ORDER BY a;
DELETE FROM tst_comps WHERE ROW(3, 'c', 3)::tst_comp_basic_t = ANY(b);
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_comps ORDER BY a;

-- test_tbl_composite_with_enums
DELETE FROM tst_comp_enum WHERE a = 1;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_comp_enum ORDER BY a;
DELETE FROM tst_comp_enum WHERE (b).a = 2.0;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_comp_enum ORDER BY a;

-- test_tbl_composite_with_enums_array
DELETE FROM tst_comp_enum_array WHERE a = ROW(1.0, 'a', 1)::tst_comp_enum_t;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_comp_enum_array ORDER BY a;
DELETE FROM tst_comp_enum_array WHERE (b[0]).b = 'b';
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_comp_enum_array ORDER BY a;
DELETE FROM tst_comp_enum_array WHERE ROW(3, 'c', 3)::tst_comp_enum_t = ANY(b);
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_comp_enum_array ORDER BY a;

-- test_tbl_composite_with_enums_array_in_composite
DELETE FROM tst_comp_one_enum_array WHERE a = 1;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_comp_one_enum_array ORDER BY a;
DELETE FROM tst_comp_one_enum_array WHERE (b).c = 2;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_comp_one_enum_array ORDER BY a;
DELETE FROM tst_comp_one_enum_array WHERE 'a' = ANY((b).b);
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_comp_one_enum_array ORDER BY a;

-- test_tbl_composite_with_enums_array_in_composite
DELETE FROM tst_comp_enum_what WHERE (a).a = 1;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_comp_enum_what ORDER BY a;
DELETE FROM tst_comp_enum_what WHERE (b[1]).a = 2;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_comp_enum_what ORDER BY a;
DELETE FROM tst_comp_enum_what WHERE (b[1]).b = '{c, a, b}';
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
SELECT a, b FROM tst_comp_enum_what ORDER BY a;

-- test_tbl_mixed_composites
DELETE FROM tst_comp_mix_array WHERE ((a).a).a = 1;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
SELECT a, b FROM tst_comp_mix_array ORDER BY a;

DROP TABLE tst_one_array;
DROP TABLE tst_arrays;
DROP TABLE tst_one_enum;
DROP TABLE tst_enums;
DROP TABLE tst_one_comp;
DROP TABLE tst_comps;
DROP TABLE tst_comp_enum;
DROP TABLE tst_comp_enum_array;
DROP TABLE tst_comp_one_enum_array;
DROP TABLE tst_comp_enum_what;
DROP TABLE tst_comp_mix_array;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c regression
\d

DROP TYPE tst_comp_mix_t;
DROP TYPE tst_comp_enum_array_t;
DROP TYPE tst_comp_enum_t;
DROP TYPE tst_comp_basic_t;
DROP TYPE tst_enum_t;
SELECT pg_xlog_wait_remote_apply(pg_current_xlog_location()::text, pid) FROM pg_stat_replication;
\c postgres
\dT