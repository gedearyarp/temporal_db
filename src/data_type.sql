CREATE TYPE public.coalesce_result AS (
	project_name text,
	start_date date,
	end_date date
);

CREATE TYPE public.join_result AS (
	team_id int4,
	team_name text,
	project_id int4,
	project_name text,
	start_date date,
	end_date date
);

CREATE TYPE PUBLIC.PROJECTION_RESULT AS
	( TEAM_NAME CHARACTER VARYING(255), START_DATE DATE, END_DATE DATE );