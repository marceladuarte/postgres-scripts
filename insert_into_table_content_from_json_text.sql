--          Table settings
-- 	Column          |   Type 
--------------------+-------------
-- 	id              | bigserial
-- 	countrycontent  | jsonb
--
--    Table newtable
-- 	Column  |   Type 
------------+-------------
-- 	id      | bigserial
-- 	name    | varchar  unique
--
--
-- Extract abbreviations from countrycontent column (settings table) and insert into "newtable"
--
-- FROM: select countrycontent from settings limit 1;
--      {
--          "BR": [
--              {
--                  "key": "name", 
--                  "value": "Brazil"
--              }, 
--              {
--                  "key": "abbreviation", 
--                  "value: "BRA"
--              }
--          ], 
--          "US": [
--              {
--                  "key": "name", 
--                  "value": "United States of America"
--              }, 
--              {
--                  "key": "abbreviation", 
--                  "value: "USA"
--              }
--          ]
--      }
--
-- To: select name from newtable;
--  BRA
--  USA

DO
$do$
DECLARE
  contentRow record;
  country text;
  countryInfo jsonb;
  infoValue jsonb;
  abbreviation text;
  
BEGIN
 FOR contentRow IN SELECT s.countryContent FROM settings s WHERE s.countryContent IS NOT NULL AND s.countryContent <> '{}' LOOP
  FOR country, countryInfo IN SELECT * FROM jsonb_each_text(contentRow.countryContent::jsonb) LOOP
   	FOR infoValue IN SELECT * FROM json_array_elements(countryInfo::json) LOOP
 		IF infoValue->>'key' = 'abbreviation' THEN
 			abbreviation := infoValue->>'value';
 			INSERT INTO newTable(name) VALUES(abbreviation) ON CONFLICT DO NOTHING;
 	   	END IF;
 	END LOOP;
  END LOOP;
 END LOOP;
END;
$do$;