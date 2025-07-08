INSERT INTO sensors (name, location, sensor_type, created_at, updated_at)
SELECT
  'sensor_' || s.id AS name,
  'datacenter_' || (s.id % 10) AS location,
  'http' AS sensor_type,
  now() - (s.id || ' minutes')::interval AS created_at,
  now() - (s.id || ' minutes')::interval AS updated_at
FROM generate_series(1, 5000) AS s(id);

-- DROP INDEXES to speed up bulk insert
DROP INDEX IF EXISTS index_pings_on_created_at;
DROP INDEX IF EXISTS index_pings_on_sensor_id;
DROP INDEX IF EXISTS index_pings_on_sensor_id_and_created_at;
DROP INDEX IF EXISTS index_pings_on_sensor_id_and_status_code;

CREATE OR REPLACE FUNCTION normal_random()
RETURNS float AS $$
DECLARE
  u1 float := random();
  u2 float := random();
BEGIN
  RETURN sqrt(-2 * ln(u1)) * cos(2 * pi() * u2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Insert 10 million rows
INSERT INTO pings (sensor_id, response_time, status_code, created_at, updated_at)
SELECT
  LEAST(GREATEST(ROUND(2500 + 700 * normal_random()), 1), 5000)::bigint AS sensor_id,
  (50 + random() * 750)::float AS response_time,
  (CASE WHEN random() < 0.97 THEN 200 ELSE 500 END)::integer AS status_code,
  (
    '2023-01-01'::timestamp +
    ((extract(epoch from now() - '2023-01-01'::timestamp) * random()) || ' seconds')::interval
  ) AS created_at,
  now() AS updated_at
FROM generate_series(1, 10000000);

-- RECREATE INDEXES after bulk insert
CREATE INDEX index_pings_on_created_at ON pings (created_at);
CREATE INDEX index_pings_on_sensor_id ON pings (sensor_id);
CREATE INDEX index_pings_on_sensor_id_and_created_at ON pings (sensor_id, created_at);
CREATE INDEX index_pings_on_sensor_id_and_status_code ON pings (sensor_id, status_code);

