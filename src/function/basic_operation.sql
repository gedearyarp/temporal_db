CREATE OR REPLACE PROCEDURE public.insert_project(IN _name character varying, IN _start_date date, IN _end_date date)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    existing_id INTEGER;
    existing_start_date DATE;
    existing_end_date DATE;
BEGIN
    -- Check if there is an existing project with the same name
    SELECT id, start_date, end_date INTO existing_id, existing_start_date, existing_end_date 
    FROM project 
    WHERE name = _name;

    -- If there is an existing project
    IF existing_id IS NOT NULL THEN
        -- Check for date overlap using the overlaps function
        IF overlaps(existing_start_date, existing_end_date, _start_date, _end_date) THEN
            -- If dates overlap, merge the periods
            UPDATE project
            SET start_date = LEAST(existing_start_date, _start_date),
                end_date = GREATEST(existing_end_date, _end_date)
            WHERE id = existing_id;
        ELSE
            -- If dates do not overlap, insert a new row
            INSERT INTO project(name, start_date, end_date) VALUES (_name, _start_date, _end_date);
        END IF;
    ELSE
        -- If there is no existing project with the same name, insert a new row
        INSERT INTO project(name, start_date, end_date) VALUES (_name, _start_date, _end_date);
    END IF;
END;
$procedure$
;

CREATE OR REPLACE PROCEDURE public.update_project(IN _id integer, IN _start_date date, IN _end_date date)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE project p
    SET start_date = _start_date,
        end_date = _end_date
    WHERE p.id = _id;
END;
$procedure$
;

CREATE OR REPLACE PROCEDURE public.delete_project(IN _id integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    DELETE FROM project p WHERE p.id = _id;
END;
$procedure$
;
