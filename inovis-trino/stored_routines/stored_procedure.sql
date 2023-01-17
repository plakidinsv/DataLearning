CREATE OR REPLACE PROCEDURE insert_procedure_info()
AS $$
DECLARE
    obj_type text;
    obj_name text;
    obj_code text;
    obj record;
    error_message text;
BEGIN
    FOR obj IN (SELECT n.nspname as schema_name, p.proname as function_procedure_name, p.prosrc as function_procedure_code
                FROM pg_proc p
                JOIN pg_namespace n ON n.oid = p.pronamespace
                WHERE n.nspname NOT LIKE 'pg_%' AND n.nspname != 'information_schema')
    LOOP
        BEGIN
            IF obj.proisagg = false THEN
                obj_type := 'function';
            ELSE
                obj_type := 'procedure';
            END IF;
            obj_name := obj.schema_name || '.' || obj.function_procedure_name;
            obj_code := obj.function_procedure_code;
            -- Добавляем информацию о функции/процедуре в таблицу stored_routines
            INSERT INTO stored_routines (type, name, code)
            VALUES (obj_type, obj_name, obj_code);
        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
            -- Добавляем информацию об ошибке в таблицу procedure_errors
            INSERT INTO procedure_errors (name, execution_time, error_message)
            VALUES (obj_name, NOW, error_message);
        END;
    END LOOP;
END; 
$$ LANGUAGE plpgsql


