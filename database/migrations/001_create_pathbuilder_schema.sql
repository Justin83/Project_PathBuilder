-- 001_create_pathbuilder_schema.sql
-- Purpose:  Create the `pathbuilder` schema, the `pathbuilder_app` login role
--           scoped only to that schema, and the initial PathBuilder tables
--           (courses, units, lessons, lesson_resources, labs, assignments,
--           weekly_plans). No KYPF or transfer_poc data is touched.
-- Author:   claude-code
-- Date:     2026-05-22
-- Status:   DRAFT — DO NOT RUN WITHOUT JUSTIN'S APPROVAL
-- Gate:     Per agentharness/DATABASE_SAFETY_PROTOCOL.md, this file must be
--           run as a dry run first (BEGIN ... ROLLBACK) and the output
--           reported to Justin. Only after Justin's explicit approval should
--           the final ROLLBACK on the last line be changed to COMMIT.
--
-- Rollback (if COMMIT was performed): see the ROLLBACK block at the bottom
--   of this file. It drops the new schema and role and is itself a
--   read-effecting change that must be approved separately.
--
-- Connection target: shared DigitalOcean managed Postgres cluster
--   (the same cluster that already holds pathfinder_performance_dev and
--   transfer_poc). Execute via the postgres MCP as `doadmin` OR via psql
--   with `op run --env-file ./agents/claude-code.env -- psql ...`.
--
-- Pre-flight checks (run these SELECTs separately before BEGIN below):
--   SELECT schema_name FROM information_schema.schemata
--    WHERE schema_name = 'pathbuilder';            -- expect 0 rows
--   SELECT rolname FROM pg_roles
--    WHERE rolname = 'pathbuilder_app';            -- expect 0 rows

BEGIN;

------------------------------------------------------------
-- 1. Schema
------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS pathbuilder;

COMMENT ON SCHEMA pathbuilder IS
  'Project PathBuilder logical namespace. Mirrors the isolation pattern '
  'used by pathfinder_performance_dev and transfer_poc in the same cluster.';

------------------------------------------------------------
-- 2. Role
------------------------------------------------------------
-- The password value is intentionally a placeholder. Replace it
-- out-of-band before COMMIT, e.g.:
--   ALTER ROLE pathbuilder_app PASSWORD '...';     -- run interactively
-- Better: create the role without a password here and SET PASSWORD
-- in a separate session that is not committed to git.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pathbuilder_app') THEN
    CREATE ROLE pathbuilder_app LOGIN PASSWORD 'CHANGE_ME_BEFORE_COMMIT';
  END IF;
END
$$;

GRANT USAGE  ON SCHEMA pathbuilder TO pathbuilder_app;
GRANT CREATE ON SCHEMA pathbuilder TO pathbuilder_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA pathbuilder
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES    TO pathbuilder_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA pathbuilder
  GRANT USAGE, SELECT                ON SEQUENCES  TO pathbuilder_app;

------------------------------------------------------------
-- 3. Initial tables (curriculum core)
------------------------------------------------------------
-- Course = a single offering (e.g., "Biology 2026 Fall co-op").
CREATE TABLE IF NOT EXISTS pathbuilder.courses (
  id            BIGSERIAL PRIMARY KEY,
  slug          TEXT NOT NULL UNIQUE,
  title         TEXT NOT NULL,
  subject       TEXT NOT NULL,             -- e.g. 'biology'
  cohort_label  TEXT,                      -- e.g. '2026-fall'
  starts_on     DATE,
  ends_on       DATE,
  notes         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Unit = a multi-week chunk of a course (e.g., "Cells and Energy").
CREATE TABLE IF NOT EXISTS pathbuilder.units (
  id            BIGSERIAL PRIMARY KEY,
  course_id     BIGINT NOT NULL REFERENCES pathbuilder.courses(id) ON DELETE CASCADE,
  ordinal       INT NOT NULL,              -- order within course
  title         TEXT NOT NULL,
  overview      TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (course_id, ordinal)
);

-- Weekly plan = a single week of the course schedule.
CREATE TABLE IF NOT EXISTS pathbuilder.weekly_plans (
  id            BIGSERIAL PRIMARY KEY,
  course_id     BIGINT NOT NULL REFERENCES pathbuilder.courses(id) ON DELETE CASCADE,
  week_number   INT NOT NULL,
  unit_id       BIGINT REFERENCES pathbuilder.units(id) ON DELETE SET NULL,
  starts_on     DATE,
  ends_on       DATE,
  theme         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (course_id, week_number)
);

-- Lesson = a discrete teaching block inside a weekly plan.
CREATE TABLE IF NOT EXISTS pathbuilder.lessons (
  id              BIGSERIAL PRIMARY KEY,
  weekly_plan_id  BIGINT NOT NULL REFERENCES pathbuilder.weekly_plans(id) ON DELETE CASCADE,
  ordinal         INT NOT NULL,
  title           TEXT NOT NULL,
  objectives      TEXT,
  body_markdown   TEXT,
  storage_key     TEXT,                    -- e.g. 'pathbuilder/biology/2026-fall/week-01/lesson-1.md'
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (weekly_plan_id, ordinal)
);

-- Lesson resource = a downloadable artifact attached to a lesson.
CREATE TABLE IF NOT EXISTS pathbuilder.lesson_resources (
  id            BIGSERIAL PRIMARY KEY,
  lesson_id     BIGINT NOT NULL REFERENCES pathbuilder.lessons(id) ON DELETE CASCADE,
  kind          TEXT NOT NULL,             -- 'handout' | 'parent-guide' | 'slides' | 'reading' | 'video'
  title         TEXT NOT NULL,
  storage_key   TEXT,                      -- Spaces object key under PATHBUILDER_STORAGE_PREFIX
  external_url  TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Lab = a campus-day or at-home lab activity.
CREATE TABLE IF NOT EXISTS pathbuilder.labs (
  id            BIGSERIAL PRIMARY KEY,
  course_id     BIGINT NOT NULL REFERENCES pathbuilder.courses(id) ON DELETE CASCADE,
  weekly_plan_id BIGINT REFERENCES pathbuilder.weekly_plans(id) ON DELETE SET NULL,
  title         TEXT NOT NULL,
  location_kind TEXT,                      -- 'campus' | 'home' | 'field'
  supplies      TEXT,
  procedure_md  TEXT,
  storage_key   TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Assignment = work assigned to students (worksheet, response, lab write-up).
-- NOTE: student-identifying fields are intentionally NOT in this initial set.
-- Per INFRASTRUCTURE.md "Do not do yet: Store student PII", student/enrollment
-- tables are deferred until the PII handling story is approved.
CREATE TABLE IF NOT EXISTS pathbuilder.assignments (
  id              BIGSERIAL PRIMARY KEY,
  weekly_plan_id  BIGINT NOT NULL REFERENCES pathbuilder.weekly_plans(id) ON DELETE CASCADE,
  lesson_id       BIGINT REFERENCES pathbuilder.lessons(id) ON DELETE SET NULL,
  title           TEXT NOT NULL,
  kind            TEXT NOT NULL,           -- 'worksheet' | 'response' | 'lab-writeup' | 'quiz'
  due_on          DATE,
  storage_key     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

------------------------------------------------------------
-- 4. Dry-run gate
------------------------------------------------------------
-- Leaving this as ROLLBACK forces this script to be a no-op when executed
-- as-is. After dry-run output is shared with Justin and approved, the line
-- below is the ONLY line to change (ROLLBACK -> COMMIT).
ROLLBACK;

------------------------------------------------------------
-- ROLLBACK / TEARDOWN (separate, manual, approval-gated)
------------------------------------------------------------
-- If the migration above is committed and later needs to be reverted, run
-- the block below in a separate session AFTER getting Justin's approval.
-- This drops all PathBuilder tables, the schema, and the role.
--
-- BEGIN;
--   DROP TABLE IF EXISTS pathbuilder.assignments       CASCADE;
--   DROP TABLE IF EXISTS pathbuilder.labs              CASCADE;
--   DROP TABLE IF EXISTS pathbuilder.lesson_resources  CASCADE;
--   DROP TABLE IF EXISTS pathbuilder.lessons           CASCADE;
--   DROP TABLE IF EXISTS pathbuilder.weekly_plans      CASCADE;
--   DROP TABLE IF EXISTS pathbuilder.units             CASCADE;
--   DROP TABLE IF EXISTS pathbuilder.courses           CASCADE;
--   REVOKE ALL ON SCHEMA pathbuilder FROM pathbuilder_app;
--   DROP SCHEMA IF EXISTS pathbuilder CASCADE;
--   DROP ROLE  IF EXISTS pathbuilder_app;
-- ROLLBACK;  -- dry-run mode for the teardown itself
-- -- After approval, change the line above to COMMIT.
