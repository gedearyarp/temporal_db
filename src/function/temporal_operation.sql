CREATE OR REPLACE FUNCTION public.temporal_join(_tbl1 text, _tbl2 text)
    RETURNS SETOF join_result
    LANGUAGE plpgsql
AS $function$
DECLARE
    _tid     integer;
    _tname   text;
    _tstart  date;
    _tend    date;
    _pid     integer;
    _pname   text;
    _pstart  date;
    _pend    date;
BEGIN
    FOR _tid, _tname, _tstart, _tend, _pid, _pname, _pstart, _pend IN EXECUTE
        format(
            $sql$
            SELECT *
            FROM  %1$I CROSS JOIN %2$I
            $sql$, _tbl1, _tbl2)
    LOOP
        IF overlaps(_tstart, _tend, _pstart, _pend) THEN 
            RETURN NEXT (_tid, _tname, _pid, _pname, _pstart, _tend);
        ELSIF overlaps(_pstart, _pend, _tstart, _tend) THEN
            RETURN NEXT (_tid, _tname, _pid, _pname, _tstart, _pend);
        ELSIF during(_tstart, _tend, _pstart, _pend) THEN
            RETURN NEXT (_tid, _tname, _pid, _pname, _tstart, _tend);
        ELSIF during(_pstart, _pend, _tstart, _tend) THEN
            RETURN NEXT (_tid, _tname, _pid, _pname, _pstart, _pend);
        END IF;
    END LOOP;
END
$function$
;
;

CREATE OR REPLACE FUNCTION public.temporal_different(_tbl1 text, _tbl2 text)
    RETURNS SETOF join_result
    LANGUAGE plpgsql
AS $function$
DECLARE
    _tid     integer;
    _tname   text;
    _tstart  date;
    _tend    date;
    _pid     integer;
    _pname   text;
    _pstart  date;
    _pend    date;
BEGIN
    FOR _tid, _tname, _tstart, _tend, _pid, _pname, _pstart, _pend IN EXECUTE
        format(
            $sql$
            SELECT *
            FROM  %1$I CROSS JOIN %2$I
            $sql$, _tbl1, _tbl2)
    LOOP
        IF overlaps(_tstart, _tend, _pstart, _pend) THEN 
            RETURN NEXT (_tid, _tname, _pid, _pname, _tstart, _pstart);
            RETURN NEXT (_tid, _tname, _pid, _pname, _tend, _pend);
        ELSIF overlaps(_pstart, _pend, _tstart, _tend) THEN
            RETURN NEXT (_tid, _tname, _pid, _pname, _pstart, _tstart);
            RETURN NEXT (_tid, _tname, _pid, _pname, _pend, _tend);
        ELSIF during(_tstart, _tend, _pstart, _pend) THEN
            RETURN NEXT (_tid, _tname, _pid, _pname, _pstart, _tstart);
            RETURN NEXT (_tid, _tname, _pid, _pname, _tend, _pend);
        ELSIF during(_pstart, _pend, _tstart, _tend) THEN
            RETURN NEXT (_tid, _tname, _pid, _pname, _tstart, _pstart);
            RETURN NEXT (_tid, _tname, _pid, _pname, _pend, _tend);
        END IF;
    END LOOP;
END
$function$
;
;

CREATE OR REPLACE FUNCTION TEMPORAL_PROJECTION(
    _TBL TEXT,
    _BASE_COL TEXT,
    _START_DATE_COL TEXT,
    _END_DATE_COL TEXT
) RETURNS SETOF PROJECTION_RESULT AS
    $$           DECLARE CURRENT_ROW RECORD;
    PREVIOUS_ROW RECORD;
BEGIN
    FOR CURRENT_ROW IN EXECUTE FORMAT('SELECT * FROM %I ORDER BY %I, %I', _TBL, _BASE_COL, _START_DATE_COL) LOOP
        IF PREVIOUS_ROW IS NULL THEN
            PREVIOUS_ROW := CURRENT_ROW;
        ELSE
            IF PREVIOUS_ROW.NAME = CURRENT_ROW.NAME AND PREVIOUS_ROW.END_PERIOD >= CURRENT_ROW.START_PERIOD THEN
                PREVIOUS_ROW.END_PERIOD := GREATEST(PREVIOUS_ROW.END_PERIOD, CURRENT_ROW.END_PERIOD);
            ELSE
                RETURN NEXT (PREVIOUS_ROW.NAME, PREVIOUS_ROW.START_PERIOD, PREVIOUS_ROW.END_PERIOD);
                PREVIOUS_ROW := CURRENT_ROW;
            END IF;
        END IF;
    END LOOP;
    IF PREVIOUS_ROW IS NOT NULL THEN
        RETURN NEXT (PREVIOUS_ROW.NAME, PREVIOUS_ROW.START_PERIOD, PREVIOUS_ROW.END_PERIOD);
    END IF;
    RETURN;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION temporal_selection(_tbl TEXT, _col TEXT, _name TEXT)
RETURNS TABLE (team_name CHARACTER VARYING(255), start_date DATE, end_date DATE) AS
$$
BEGIN
    RETURN QUERY
    SELECT tp.team_name, tp.start_date, tp.end_date
    FROM temporal_projection(_tbl, _col, 'start_period', 'end_period') AS tp
    WHERE tp.team_name = _name;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION temporal_union()
RETURNS TABLE(name VARCHAR(255), start_date DATE, end_date DATE) AS
$$
DECLARE
    project_row RECORD;
    team_row RECORD;
    overlapping BOOLEAN;
BEGIN
    -- Loop through project table
    FOR project_row IN (SELECT * FROM project)
    LOOP
        overlapping := FALSE; -- Flag to track overlapping rows
        
        -- Check if the project row overlaps with any team row
        FOR team_row IN (SELECT * FROM teams t WHERE t.name = project_row.name)
        LOOP
            IF overlaps(project_row.start_date, project_row.end_date, team_row.start_period, team_row.end_period) THEN
                -- If overlap is found, merge dates and set the flag
                overlapping := TRUE;
				name := project_row.name;
                start_date := LEAST(project_row.start_date, team_row.start_period);
                end_date := GREATEST(project_row.end_date, team_row.end_period);
				RETURN NEXT;
                EXIT; -- Exit the inner loop
			ELSE
				name := team_row.name;
				start_date := team_row.start_period;
				end_date := team_row.end_period;
				RETURN NEXT;
            END IF;
        END LOOP;

        -- If no overlap is found, return the project row as is
        IF NOT overlapping THEN
            name := project_row.name;
            start_date := project_row.start_date;
            end_date := project_row.end_date;
            RETURN NEXT;
        END IF;
    END LOOP;

    -- Loop through team table
    FOR team_row IN (SELECT * FROM teams t WHERE t.name NOT IN (SELECT p.name FROM project p))
    LOOP
        name := team_row.name;
        start_date := team_row.start_period;
        end_date := team_row.end_period;
        RETURN NEXT;
    END LOOP;

    RETURN;
END;
$$ LANGUAGE plpgsql;


​​CREATE OR REPLACE FUNCTION temporal_timeslice(table_name VARCHAR(255), col_start VARCHAR(255), col_end VARCHAR(255), time_input DATE)
RETURNS TABLE(id INTEGER, name VARCHAR(255), start_date DATE, end_date DATE) AS
$$
DECLARE
    sql_query TEXT;
BEGIN
    sql_query := 'SELECT * FROM ' || table_name || 
                 ' WHERE ' || col_start || ' <= $1 AND ' || col_end || '>= $1';

    RETURN QUERY EXECUTE sql_query USING time_input;
END;
$$ LANGUAGE plpgsql;

;

