CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS incidents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  location GEOGRAPHY(POINT, 4326) NOT NULL,
  lat DOUBLE PRECISION GENERATED ALWAYS AS (ST_Y(location::geometry)) STORED,
  lng DOUBLE PRECISION GENERATED ALWAYS AS (ST_X(location::geometry)) STORED,
  severity TEXT CHECK (severity IN ('LOW','MEDIUM','HIGH','CRITICAL')),
  ml_severity_score FLOAT,
  status TEXT DEFAULT 'ACTIVE',
  reporter_id UUID,
  vehicle_type TEXT,
  road_type TEXT,
  weather TEXT,
  photo_url TEXT,
  voice_note_url TEXT,
  qr_code_id TEXT UNIQUE,
  qr_payload TEXT
);

CREATE TABLE IF NOT EXISTS profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT,
  location GEOGRAPHY(POINT, 4326),
  certification_level INT DEFAULT 0,
  response_rate FLOAT DEFAULT 0,
  is_stationary BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS bystander_responses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  incident_id UUID REFERENCES incidents(id),
  user_id UUID,
  role TEXT,
  accepted_at TIMESTAMPTZ,
  arrived_at TIMESTAMPTZ,
  certification_level INT DEFAULT 0
);

CREATE INDEX IF NOT EXISTS incidents_location_idx ON incidents USING GIST(location);
CREATE INDEX IF NOT EXISTS profiles_location_idx ON profiles USING GIST(location);

CREATE OR REPLACE FUNCTION rank_nearby_bystanders(
  p_lat DOUBLE PRECISION,
  p_lng DOUBLE PRECISION,
  p_radius_meters INT DEFAULT 500
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  certification_level INT,
  response_rate FLOAT,
  distance_meters FLOAT,
  rank_score FLOAT
)
LANGUAGE sql
STABLE
AS $$
  WITH origin AS (
    SELECT ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography AS geog
  )
  SELECT
    p.id,
    p.name,
    p.certification_level,
    p.response_rate,
    ST_Distance(p.location, origin.geog) AS distance_meters,
    (
      (p.certification_level * 0.3) +
      ((1 / GREATEST(ST_Distance(p.location, origin.geog), 1)) * 0.4) +
      (COALESCE(p.response_rate, 0) * 0.2) +
      (CASE WHEN p.is_stationary THEN 0.1 ELSE 0 END)
    ) AS rank_score
  FROM profiles p, origin
  WHERE p.location IS NOT NULL
    AND ST_DWithin(p.location, origin.geog, p_radius_meters)
  ORDER BY rank_score DESC
  LIMIT 5;
$$;
