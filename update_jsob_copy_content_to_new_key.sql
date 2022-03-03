--          Table settings
-- 	Column          |   Type 
--------------------+-------------
-- 	id              | bigserial
-- 	citiescontent   | jsonb
--
-- Update citiescontent column 
-- From: 
--      {
--          "cities": [
--              {
--                  "id": 1, 
--                  "name": "New York"
--              }, 
--              {
--                  "id": 2, 
--                  "name": "Los Angeles"
--              }, 
--              {
--                  "id": 3, 
--                  "name": "Denver"
--              }
--          ]
--      }
--
-- To:
--      {
--          "cities": {
--              "US": [
--                  {
--                      "id": 1, 
--                      "name": "New York"
--                  }, 
--                  {
--                      "id": 2, 
--                      "name": "Los Angeles"
--                  }, 
--                  {
--                      "id": 3, 
--                      "name": "Denver"
--                  }
--              ]
--          }
--      }

DO
$do$
    DECLARE
		recordRow record;
		originalContent jsonb;
		citiesByContry jsonb;
		country text;
    BEGIN
        FOR recordRow IN SELECT id, citiescontent FROM settings WHERE citiescontent IS NOT NULL LOOP
			originalContent := recordRow.citiescontent->'cities';
			citiesByContry := '{}';

			IF originalContent IS NULL OR originalContent = '{}' THEN
				originalContent := '[]';
			END IF;

			citiesByContry := jsonb_build_object('US', originalContent);
			UPDATE settings SET citiescontent = jsonb_build_object('cities', citiesByContry) WHERE id = recordRow.id;
        END LOOP;
    END;
$do$;