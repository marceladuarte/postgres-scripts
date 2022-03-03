--          Table user
-- 	Column      |   Type 
----------------+-------------
-- 	id          | bigserial
-- 	preferences | jsonb
--
-- Update preferences column 
-- From: 
--      {
--          "preferences": {
--              "MX":{
--                  "JA": "Puerto Vallarta",
--                  "MX": "Mexico City",
--                  "QI": "Cancun"
--              },
--              "US": {
--                  "CA": "Los Angeles", 
--                  "FL": "Orlando",
--                  "NY": "New York"
--              }
--          }
--      }
--
-- To: 
--      {
--          "preferences": {
--              "MX": [
--                  {
--                      "key": "JA", 
--                      "value": "Puerto Vallarta"
--                  }, 
--                  {
--                      "key": "MX", 
--                      "value": "Mexico City"
--                  }, 
--                  {
--                      "key": "QI", 
--                      "value": "Cancun"
--                  }
--              ], 
--              "US": [
--                  {
--                      "key": "CA", 
--                      "value": "Los Angeles"
--                  }, 
--                  {
--                      "key": "FL", 
--                      "value": "Orlando"
--                  }, 
--                  {
--                      "key": "NY", 
--                      "value": "New York"
--                  }
--              ]
--          }
--      }
--
--
-- It's important to notice that in objects the order is not preserved so in the json if the first key were US and then MX, 
-- or in the US object the order were NY, CA and FL,  the result would still be the same (it's sorting in alphabetical order)

UPDATE user up SET preferences = preferences.content 
    FROM (
        SELECT preferencesgroup.id, jsonb_build_object('preferences',preferencesgroup.json_content) AS content
            FROM (SELECT result.id, json_object_agg(result.country, result.obj) AS json_content
                FROM (SELECT u.id AS id, 'US' AS country, json_agg(jsonb_build_object('key', us.key, 'value', us.value)) AS obj
					    FROM user u, jsonb_each_text(u.preferences->'preferences'->'US') AS us 
                        GROUP BY u.id
                    UNION ALL
					SELECT u.id AS id, 'MX' AS country, json_agg(jsonb_build_object('key', mx.key, 'value', mx.value)) AS obj
						FROM user u, jsonb_each_text(u.preferences->'preferences'->'MX') AS mx
                        GROUP BY u.id
				) AS result GROUP BY result.id
			) preferencesgroup
		)preferences
WHERE up.id = preferences.id;
