UPDATE customer_orders
SET extras = ''
WHERE extras IS NUll
	OR extras = 'null';

UPDATE customer_orders
SET exclusions = ''
WHERE exclusions IS NULL
	OR exclusions = 'null';

UPDATE runner_orders
SET distance = REPLACE(distance,'km','');
UPDATE runner_orders
-- agarrar los minutes/min, borrarlos y pasar la columna a tiempo
UPDATE runner_orders
SET distance = Null
WHERE distance = 'null';

ALTER TABLE runner_orders
ALTER COLUMN pickup_time TYPE TIMESTAMP without time zone
USING pickup_time::timestamp;

SELECT distance
FROm runner_orders
