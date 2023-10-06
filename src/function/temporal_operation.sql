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