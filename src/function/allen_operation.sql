CREATE OR REPLACE FUNCTION public.during(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN start1 > start2 AND end1 < end2;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.during_inversed(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN during(start2, end2, start1, end1);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.finishes(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN start1 > start2 AND end1 = end2;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.finishes_inversed(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN finishes(start2, end2, start1, end1);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_after(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN start1 > end2;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_before(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN end1 < start2;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_equal(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN start1 = start2 AND end1 = end2;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.meets(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN end1 = start2 AND start1 < start2;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.meets_inversed(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN meets(start2, end2, start1, end1);
END;
$function$
;

CREATE OR REPLACE FUNCTION public."overlaps"(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN start1 < start2 AND end1 > start2 AND end1 < end2;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.overlaps_inversed(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN overlaps(start2, end2, start1, end1);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.starts(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN start1 = start2 AND end1 < end2;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.starts_inversed(start1 date, end1 date, start2 date, end2 date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN starts(start2, end2, start1, end1);
END;
$function$
;
