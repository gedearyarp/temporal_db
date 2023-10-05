CREATE OR REPLACE FUNCTION public.temporal_coalesce(_tbl text, _base_col text, _start_date_col text, _end_date_col text)
    RETURNS SETOF coalesce_result
    LANGUAGE plpgsql
AS $function$
DECLARE
    _lower     date;
    _upper     date;
    _startdate date;
    _enddate   date;
    _project_temp   text;
    _project_bef   text;
begin
    FOR _lower, _upper, _project_temp IN EXECUTE
        format(
            $sql$
            SELECT COALESCE(t.%3$I,'-infinity')
                , COALESCE(t.%4$I, 'infinity')
                , t.%2$I 
            FROM   %1$I t
            ORDER  BY t.%2$I, t.%3$I, t.%4$I
            $sql$, _tbl, _base_col, _start_date_col, _end_date_col)
    loop
        if _project_bef IS NULL then 
            SELECT _lower, _upper  INTO _startdate, _enddate;
        elsif _project_bef != _project_temp then
            RETURN NEXT (_project_bef, _startdate, _enddate);
            SELECT _lower, _upper  INTO _startdate, _enddate;
        ELSIF _lower > _enddate THEN
            RETURN NEXT (_project_bef, _startdate, _enddate);
            SELECT _lower, _upper  INTO _startdate, _enddate;
        ELSIF _upper > _enddate THEN  
            _enddate := _upper;
        ELSIF _enddate IS NULL THEN 
            SELECT _lower, _upper  INTO _startdate, _enddate;
        END IF;

        select _project_temp into _project_bef;
    END LOOP;

    IF FOUND THEN
        RETURN NEXT (_project_bef, _startdate, _enddate);
    END IF;
END
$function$
;

;
