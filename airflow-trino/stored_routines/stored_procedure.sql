CREATE OR REPLACE PROCEDURE insert_procedure_info()
AS $$
DECLARE
    obj_type text;
    obj_name text;
    obj_code text;
    obj record;
    error_message text;
BEGIN
    FOR obj IN (SELECT n.nspname as schema_name, p.proname as function_procedure_name, p.prokind, p.prosrc as function_procedure_code
                FROM pg_proc p
                JOIN pg_namespace n ON n.oid = p.pronamespace
                WHERE n.nspname NOT LIKE 'pg_%' AND n.nspname != 'information_schema')
    LOOP
        BEGIN
            IF obj.prokind = 'f' THEN
                obj_type := 'function';
            ELSE
                obj_type := 'procedure';
            END IF;
            obj_name := obj.schema_name || '.' || obj.function_procedure_name;
            obj_code := obj.function_procedure_code;
<<<<<<< Updated upstream:airflow-trino/stored_routines/stored_procedure.sql
            -- Добавляем информацию о функции/процедуре в таблицу stored_routines            
            IF EXISTS (SELECT 1 FROM public.stored_routines 
=======
            -- Добавляем информацию о функции/процедуре в таблицу stored_routines
			IF EXISTS (SELECT 1 FROM public.stored_routines 
>>>>>>> Stashed changes:inovis-trino/stored_routines/stored_procedure.sql
      				   WHERE type = obj_type AND name = obj_name)
				THEN 
            	UPDATE public.stored_routines
				SET code = obj_code
				WHERE type = obj_type AND name = obj_name AND code != obj_code;
			ELSE
				INSERT INTO public.stored_routines (type, name, code)
				VALUES (obj_type, obj_name, obj_code);
			END IF;
        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
            -- Добавляем информацию об ошибке в таблицу procedure_errors
            INSERT INTO public.procedure_errors (name, execution_time, error_message)
            VALUES (obj_name, NOW(), error_message);
        END;
    END LOOP;
END; 
<<<<<<< Updated upstream:airflow-trino/stored_routines/stored_procedure.sql
$$ LANGUAGE plpgsql;
=======
$$ LANGUAGE plpgsql;


>>>>>>> Stashed changes:inovis-trino/stored_routines/stored_procedure.sql
