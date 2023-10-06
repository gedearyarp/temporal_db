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