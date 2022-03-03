--          Table settings
-- 	Column          |   Type 
--------------------+-------------
-- 	id              | bigserial
-- 	countrycontent  | jsonb
--
-- Update citiescontent column 
-- From: 
--      {
--          "BR": true, 
--          "US": false
--      }
--
-- To:
--      {
--          "BR": {
--              "enabled": true, 
--              "preferences": null
--          }, 
--          "US": {
--              "enabled": false, 
--              "preferences": null
--          }
--      }

DO
$do$
    DECLARE
		recordRow record;
		originalContent jsonb;
		newContent jsonb;
		newContentByCountry jsonb;
		country text;
		booleanOption bool;
    BEGIN
        FOR recordRow IN SELECT id, countryContent FROM settings WHERE countrycontent IS NOT NULL LOOP
			originalContent := recordRow.countryContent;
			newContent := '{}';

			FOR country IN SELECT * FROM jsonb_object_keys(originalContent) LOOP
				booleanOption := originalContent->country;
				newContentByCountry := jsonb_build_object('enabled', booleanOption, 'preferences', null);
				newContent := newContent || jsonb_build_object(country, newContentByCountry);
			END LOOP;

			UPDATE settings SET countryContent = newContent WHERE id = recordRow.id;
        END LOOP;
    END;
$do$;